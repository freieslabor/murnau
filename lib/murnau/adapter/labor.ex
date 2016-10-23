defmodule Murnau.Adapter.Labor do
  @moduledoc """
  Provides all logic to handle Labor specific actions.
  """
  alias Murnau.Adapter.Labor.Api, as: Api
  alias Murnau.Adapter.Telegram
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
    GenServer.start_link(__MODULE__, %{}, name: {:global, {:chat, @chat_id}})
  end

  def start_link(chat_id) do
    GenServer.start_link(__MODULE__, %{chat_id: chat_id}, [name: {:global, {:chat, chat_id}}, debug: [:trace, :statistics]])
  end

  def init(state) do
    state = Map.put(state, :pid, self())
    {:ok, state}
  end

  @doc "Returns all commands the chat supports."
  @spec commands(pid) :: {atom, map}
  def commands(pid), do: GenServer.call(pid, {:commands})

  @doc "Process an update from the server."
  @spec accept(pid, Murnau.Adapter.Telegram.Update.t) :: {atom, map}
  def accept(pid, message), do: GenServer.cast(pid, {:accept, message})

  @doc false
  def handle_call({:commands}, _from, state) do
    {:reply, @commands, state}
  end

  @doc false
  def handle_cast({:accept, msg}, state = %{countdown_tref: timer}) do
    Logger.debug "#{__MODULE__}.handle_call({:accept}). Last respose was"

    state =
      state
      |> Map.put(:message, msg.message)
      |> Map.put(:id, msg.message.chat.id)
      |> route

    Process.cancel_timer(state.open_tref)
    Process.cancel_timer(timer)

    open_tref =
    if Api.room_is_open? do
      Process.send_after(state.pid, {:heartbeat}, @open_timeout)
    else
      nil
    end

    state =
    if Api.room_is_open? do
      Map.put(state, :open_tref, open_tref)
    else
      state
    end

    {:noreply, state}
  end

  @doc false
  def handle_cast({:accept, %{message: msg}}, state = %{chat_id: chat_id}) do
    state = Map.put(state, :message, msg)
    chat = msg.chat

    case chat.id do
      ^chat_id -> {:noreply, state |> route}
      _ -> {:noreply, state}
    end
  end

  @doc false
  def handle_info({:heartbeat}, state) do
    Logger.debug "#{__MODULE__}.handle_info: :heartbeat"

    {:ok, last_response} =
    if Api.room_is_open? do
        @ctrl.send_message(state.message.chat, "Ist noch jemand im Labor?")
    end

    state =
    if Api.room_is_open? do
      Map.put(state, :last_response, last_response)
    else
      state
    end

    if Api.room_is_open? do
      Process.send_after(state.pid, {:countdown, @close_countdown_minutes},
        5 * 1000)
    end
    {:noreply, state}
  end

  @doc false
  def handle_info({:countdown, count}, state) when count < 1 do
    Process.send_after(state.pid, {:autoclose}, 1000)
    {:noreply, state}
  end
  @doc false
  def handle_info({:countdown, count}, state) do
    Logger.debug "#{__MODULE__}.handle_info: :countdown"

    count_tref =
    if Api.room_is_open? do
      @ctrl.edit_message(state.last_response, "Ist noch jemand im Labor? Ich schliesse in #{count}min wenn keiner irgendwas sagt.")
      Process.send_after(state.pid, {:countdown, count - 2}, 2 * 60 * 1000)
    end

    state =
    if Api.room_is_open? do
      Map.put(state, :countdown_tref, count_tref)
    else
      state
    end

    {:noreply, state}
  end

  @doc false
  def handle_info({:autoclose}, state) do
    Logger.debug "#{__MODULE__}.handle_info: :autoclose"

    {:ok, last_response} =
    if Api.room_is_open? do
      Api.room_close
      @ctrl.send_message(state.message.chat, "Sorry. We're closed.")
      @ctrl.send_message(state.message.chat, "Nehm ich an.")
    end

    state =
    if Api.room_is_open? do
      Map.put(state, :last_response, last_response)
    else
      state
    end
    {:noreply, state}
  end

  @doc false
  defp route(state) do
    cmd =
    if state.message.text, do: state.message.text |> String.lstrip(?/), else: ""

    case Murnau.Helper.nearest_match(@commands, cmd) do
      {:okay, func} -> run_func(func, state)
      {:error, _} -> state
    end
  end

  @doc false
  defp run_func(nil, _), do: nil
  defp run_func(func, state) do
    {state, {:ok, last_response}} = apply(__MODULE__, func, [state])
    Map.put(state, :last_response, last_response)
  end

  @doc false
  def open(state) do
    Api.room_open

    {state, @ctrl.send_message(state.message.chat, "Come in. We're open.")}
  end

  @doc false
  def close(state) do
    Api.room_close

    {state, @ctrl.send_message(state.message.chat, "Sorry. We're closed.")}
  end

  @doc false
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
