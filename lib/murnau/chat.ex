defmodule Murnau.Chat do
  @moduledoc """
  Generic telegram chat handler
  """
  alias Murnau.Adapter.Telegram
  require Logger
  use GenServer

  @vsn "0"
  @ctrl Application.get_env(:murnau, :ctrl_api)
  @commands %{"help" => :help, "timer" => :timer}
  @env Mix.env

  def start_link(msg) do
    state =
      Map.put(%{}, :message, msg.message)
      |> Map.put(:chat_id, msg.message.chat.id)

    GenServer.start_link(__MODULE__, state, [name: {:global, {:chat, msg.message.chat.id}}, debug: [:trace, :statistics]])
  end

  def init(state) do
    say(state, "Morgähn!")

    {:ok, state}
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

  def handle_cast(:help, state = %{chat_id: chat_id}) do
    say(state, "AAAaaargghh! Ich stöörbe")

    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    say(state, "AAAaaargghh! Ich stöörbe")

    {:noreply, state}
  end

  defp route(state) do
    cmd =
    if state.message.text, do: state.message.text |> String.lstrip(?/), else: ""

    case Murnau.Helper.nearest_match(@commands, cmd) do
      {:okay, func} -> run_func(func, state)
      {:error, _} -> unknown_command(state)
    end
  end

  defp run_func(func, state) do
    {state, {:ok, _}} = apply(__MODULE__, func, [state])
    state
  end

  defp unknown_command(state) do
    say(state, "Sprichst du mit mir?!")
    help(state)
  end

  def help(state) do
    say(state, "Ich versteh nur:")
    Enum.map(@commands, fn{k,v} -> say(state, "/#{k}") end)
    {state, {:ok, []}}
  end

  @doc "Send text to chat."
  def say(state, text) do
    Logger.debug "#{__MODULE__}.say: #{text}"
    {state, @ctrl.send_message(state.message.chat, text)}
  end

  def timer(state) do
    {:ok, pid} = Murnau.Timeout.start_link(self)
    Murnau.Timeout.register(pid, :help)
    Murnau.Timeout.rewind(pid, fn(p) -> true end, 50)

    {state, {:ok, []}}
  end
end
