defmodule Murnau.Adapter.Labor do
  @moduledoc """
  Provides all logic to handle Labor specific actions.
  """
  alias Murnau.Adapter.Labor.Api, as: Api
  require Logger
  use GenServer

  @vsn "0"
  @chat_id Application.get_env(:murnau, :labor_chat_id)
  @ctrl Application.get_env(:murnau, :ctrl_api)
  @commands %{"open" => :open, "close" => :close, "room" => :room}
  @open_timeout Application.get_env(:murnau, :open_timeout)
  @close_countdown_minutes 10
  @env Mix.env

  def start_link() do
    Logger.debug "#{__MODULE__}.start_link()"
    GenServer.start_link(__MODULE__, %{}, name: {:global, {:chat, @chat_id}})
  end

  def init(state) do
    state = Map.put(state, :pid, self())
    {:ok, state}
  end

  def handle_call({:commands}, _from, state) do
    Logger.debug "#{__MODULE__}.handle_call({:commands})"
    {:reply, @commands, state}
  end

  def handle_call(_, _from, _state) do
    {:reply, :error}
  end

  def handle_cast({:accept, msg}, state = %{countdown_tref: timer}) do
    Logger.debug "#{__MODULE__}.handle_call({:accept}). Last respose was"

    state =
      state
      |> Map.put(:message, msg.message)
      |> Map.put(:id, msg.message.chat.id)
      |> route

    Process.cancel_timer(state.open_tref)
    Process.cancel_timer(timer)
    if Api.room_is_open? do
      open_tref = Process.send_after(state.pid, {:heartbeat}, @open_timeout)
      state = Map.put(state, :open_tref, open_tref)
    end

    {:noreply, state}
  end
  def handle_cast({:accept, msg}, state) do
    Logger.debug "#{__MODULE__}.handle_call({:accept})."

    state =
      state
      |> Map.put(:message, msg.message)
      |> Map.put(:id, msg.message.chat.id)
      |> route

    {:noreply, state}
  end

  def handle_cast(msg, _state) do
    Logger.debug "#{__MODULE__}.handle_cast :error"
    {:noreply, :error}
  end

  def handle_info({:heartbeat}, state) do
    Logger.debug "#{__MODULE__}.handle_info: :heartbeat"
    if Api.room_is_open? do
      {:ok, last_response} =
        @ctrl.send_message(state.message.chat, "Ist noch jemand im Labor?")
      state = Map.put(state, :last_response, last_response)
      Process.send_after(state.pid, {:countdown, @close_countdown_minutes},
        5 * 1000)
    end
    {:noreply, state}
  end

  def handle_info({:countdown, count}, state) when count < 1 do
    Process.send_after(state.pid, {:autoclose}, 1000)
    {:noreply, state}
  end
  def handle_info({:countdown, count}, state) do
    Logger.debug "#{__MODULE__}.handle_info: :countdown"

    if Api.room_is_open? do
      @ctrl.edit_message(state.last_response, "Ist noch jemand im Labor? Ich schliesse in #{count}min wenn keiner irgendwas sagt.")
      count_tref = Process.send_after(state.pid, {:countdown, count - 2}, 2 * 60 * 1000)
      state = Map.put(state, :countdown_tref, count_tref)
    end
    {:noreply, state}
  end

  def handle_info({:autoclose}, state) do
    Logger.debug "#{__MODULE__}.handle_info: :autoclose"
    if Api.room_is_open? do
      Api.room_close
      @ctrl.send_message(state.message.chat, "Sorry. We're closed.")
      {:ok, last_response} =
        @ctrl.send_message(state.message.chat, "Nehm ich an.")
      state = Map.put(state, :last_response, last_response)
    end
    {:noreply, state}
  end

  defp route(state) do
    cmd = state.message.text |> String.lstrip(?/)
    {_, func} = Murnau.Helper.nearest_match(@commands, cmd)
    if func do
      func |> run_func(state)
    else
      state
    end
  end

  defp run_func(nil, _) do
    Logger.debug "#{__MODULE__}._run_func: unknown command"
  end

  defp run_func(func, state) do
    Logger.debug "#{__MODULE__}.run_cmd: #{func}"
    {state, {:ok, last_response}} = apply(__MODULE__, func, [state])
    Map.put(state, :last_response, last_response)
  end

  def open(state = %{pid: _parent})
  when @env == :dev do
    Logger.debug "#{__MODULE__}.open"

    Api.room_open
    open_tref = Process.send_after(state.pid, {:heartbeat}, @open_timeout)
    state = Map.put(state, :open_tref, open_tref)

    {state, @ctrl.send_message(state.message.chat, "Come in. We're open.")}
  end
  def open(state = %{pid: _parent, message: %{chat: %{id: chat_id}}})
  when chat_id == @chat_id do
    Logger.debug "#{__MODULE__}.open"

    Api.room_open
    open_tref = Process.send_after(state.pid, {:heartbeat}, @open_timeout)
    state = Map.put(state, :open_tref, open_tref)

    {state, @ctrl.send_message(state.message.chat, "Come in. We're open.")}
  end
  def open(state = %{message: %{chat: %{id: chat_id}}})
  when chat_id != @chat_id do
    Logger.debug "#{__MODULE__}.open: un-authorized"
    {state, @ctrl.send_message(state.message.chat, "You're not allowed to do this.")}
  end


  def close(state = %{message: %{chat: %{id: chat_id}}})
  when chat_id == @chat_id do
    Logger.debug "#{__MODULE__}.close"

    Api.room_close

    if Map.get(state, :open_tref) do
      Process.cancel_timer(state.open_tref)
      state = Map.delete(state, :open_tref)
    end
    if Map.get(state, :countdown_tref) do
      Process.cancel_timer(state.countdown_tref)
      state = Map.delete(state, :countdown_tref)
    end
    {state, @ctrl.send_message(state.message.chat, "Sorry. We're closed.")}
  end
  def close(state)
  when @env == :dev do
    Logger.debug "#{__MODULE__}.close"

    Api.room_close

    if Map.get(state, :open_tref) do
      Process.cancel_timer(state.open_tref)
      state = Map.delete(state, :open_tref)
    end
    if Map.get(state, :countdown_tref) do
      Process.cancel_timer(state.countdown_tref)
      state = Map.delete(state, :countdown_tref)
    end
    {state, @ctrl.send_message(state.message.chat, "Sorry. We're closed.")}
  end
  def close(state) do
    Logger.debug "#{__MODULE__}.close: un-authorized"
    {state, @ctrl.send_message(state.message.chat, "You're not allowed to do this.")}
  end

  def room(state) do
    btns = [["/open", "/close"]]
    keyboard = %Murnau.Adapter.Telegram.ReplyKeyboardMarkup{keyboard: btns,
                                                        resize_keyboard: true,
                                                        one_time_keyboard: true,
                                                        selective: true}
    {:ok, keyboard} = Poison.encode(keyboard)
    {state, @ctrl.send_message(state.message.chat, "Room status:", keyboard)}
  end
end
