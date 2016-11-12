defmodule Murnau.Adapter.Telegram.Chat.Labor do
  @moduledoc """
  Provides all logic to handle Labor specific actions.
  """
  use Murnau.Adapter.Telegram.Chat.Base
  alias Murnau.Adapter.Labor.Api, as: Api
  alias Murnau.Adapter.Telegram
  require Logger

  @vsn "0"
  @commands %{"open" => :open, "close" => :close, "brutalkill" => :kill}
  @open_timeout Application.get_env(:murnau, :open_timeout)
  @wait_timeout Application.get_env(:murnau, :wait_timeout)
  @retry_timeout Application.get_env(:murnau, :retry_timeout)

  def init(state) do
    Process.flag(:trap_exit, true)

    state = set_commands(state, @commands)

    say(state, "Morgähn!")
    say(state, "Mal sehen, ob das Labor schon auf ist...")

    if Api.room_is_open?(self) do
      open(state)
    else
      say(state, "Sieht nicht so aus.")
    end

    {:ok, state}
  end

  defp unknown_command(state) do
    say(state, "Sprichst du mit mir?!")
    help(state)
  end

  def help(state) do
    say(state, "Ich versteh nur:")
    Enum.map(state.commands, fn{k,v} -> say(state, "/#{k}") end)
    {state, {:ok, []}}
  end

  def route(state) do
    case String.starts_with?(state.message.text, "/") do
      true -> do_route(state)
      _ -> do_textcheck(state)
    end
  end

  defp do_textcheck(state) do
    state =
    if Map.get(state, :waiting_reply) == true do

      say(state, "Alles klar! Ich frag' später nochmal nach.")

      stop_countdown(state)
      |> start_countdown(:heartbeat, @retry_timeout * 60)
    end

    state
  end

  defp do_route(state) do
    cmd =
    if state.message.text, do: state.message.text |> String.lstrip(?/), else: ""

    case Murnau.Helper.nearest_match(state.commands, cmd) do
      {:okay, func} -> run_func(func, state)
      {:error, _} -> unknown_command(state)
    end
  end

  @doc false
  def handle_cast(:heartbeat, state) do
    if Api.room_is_open?(self) do
      say(state, "Ist noch jemand im Labor? Einfach irgendwas schreiben und ich bin still.")
      say(state, "Ansonsten mache ich das Labor in 10min zu.")
    end

    state =
      start_countdown(state, :autoclose, @wait_timeout)
      |> Map.put(:waiting_reply, true)

    {:noreply, state}
  end

  @doc false
  def handle_cast(:autoclose, state) do
    Logger.debug "#{__MODULE__}.handle_info: :autoclose"

    if Api.room_is_open?(self) do
      Api.room_close
      @ctrl.send_message(state.message.chat, "Sorry. We're closed.")
      @ctrl.send_message(state.message.chat, "Nehm ich an.")
    end

    {:noreply, Map.put(state, :waiting_reply, false)}
  end

  defp start_countdown(state, callback, timeout) do
    {:ok, pid} = Murnau.Timeout.start_link(self)
    Murnau.Timeout.register(pid, callback)
    Murnau.Timeout.rewind(pid, &Api.room_is_open?/1, timeout * 60)

    Map.put(state, :waiting_pid, pid)
  end

  defp stop_countdown(state) do
    if Map.has_key?(state, :waiting_pid) do
      Process.unlink(state.waiting_pid)
      Murnau.Timeout.stop(state.waiting_pid)
    end

    state =
      Map.delete(state, :waiting_pid)
      |> Map.delete(:waiting_reply)
  end

  def kill(state) do
    Process.exit(self, :kill)
    {state, {:ok, []}}
  end

  @doc false
  def open(state) do
    Api.room_open

    state = start_countdown(state, :heartbeat, @open_timeout)

    say(state, "Come in. We're open.")

    {state, {:ok, []}}
  end

  @doc false
  def close(state) do
    if Api.room_is_open?(self) do
      Api.room_close

      state = stop_countdown(state)

      say(state, "Sorry. We're closed.")
    end

    {state, {:ok, []}}
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
