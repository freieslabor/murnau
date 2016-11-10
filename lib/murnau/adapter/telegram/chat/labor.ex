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
  @env Mix.env

  def init(state) do
    Process.flag(:trap_exit, true)

    state = set_commands(state, @commands)

    say(state, "Morgähn!")
    say(state, "Mal sehen, ob das Labor schon auf ist...")

    if Api.room_is_open? do
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

  @doc false
  def handle_info({:heartbeat}, state) do
    if Api.room_is_open? do
      say(state, "Ist noch jemand im Labor? Einfach irgendwas schreiben und ich bin still.")
      say(state, "Ansonsten mache ich das Labor in 10min zu.")
    end

    {:ok, pid} = Murnau.Timeout.start_link(self)
    Murnau.Timeout.register(pid, :autoclose)
    Murnau.Timeout.rewind(pid, Api.room_is_open?, 60*10)

    {:noreply, state}
  end

  @doc false
  def handle_info({:autoclose}, state) do
    Logger.debug "#{__MODULE__}.handle_info: :autoclose"

    if Api.room_is_open? do
      Api.room_close
      @ctrl.send_message(state.message.chat, "Sorry. We're closed.")
      @ctrl.send_message(state.message.chat, "Nehm ich an.")
    end

    {:noreply, state}
  end

  def kill(state) do
    Process.exit(self, :kill)
    {state, {:ok, []}}
  end

  @doc false
  def open(state) do
    Api.room_open

    {:ok, pid} = Murnau.Timeout.start_link(self)
    Murnau.Timeout.register(pid, :heartbeat)
    Murnau.Timeout.rewind(pid, Api.room_is_open?, 60*60*8)

    say(state, "Come in. We're open.")

    {state, {:ok, []}}
  end

  @doc false
  def close(state) do
    Api.room_close

    say(state, "Sorry. We're closed.")

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
