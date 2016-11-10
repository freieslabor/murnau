defmodule Murnau.Adapter.Telegram.Chat.Base do
  @moduledoc """
  Generic telegram chat handler
  """
  alias Murnau.Adapter.Telegram
  use GenServer

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Telegram.Chat

      require Logger

      @ctrl Application.get_env(:murnau, :ctrl_api)

      def start_link(msg, id) do
	GenServer.start_link(__MODULE__, %{message: msg},
	  [name: {:global, {:chat, id}}, debug: [:trace, :statistics]])
      end

      def set_commands(state, cmds) do
	state = Map.put(state, :commands, cmds)
      end

      @doc "Process an update from the server."
      def handle_cast({:accept, %{message: msg}}, state) do
	state = Map.put(state, :message, msg)

	{:noreply, route(state)}
      end

      def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
	say(state, "AAAaaargghh! Ich stöörbe")

	{:noreply, state}
      end

      def terminate(reason, state) do
	IO.puts "Going down: #{inspect(state)}"
	:normal
      end

      defp route(state) do
	cmd =
	if state.message.text, do: state.message.text |> String.lstrip(?/), else: ""

	case Murnau.Helper.nearest_match(state.commands, cmd) do
	  {:okay, func} -> run_func(func, state)
	  {:error, _} -> unknown_command(state)
	end
      end

      defp run_func(func, state) do
	Logger.debug "#{__MODULE__}.apply"
	{state, {:ok, _}} = apply(__MODULE__, func, [state])
	IO.inspect state
	state
      end

      @doc "Send text to chat."
      def say(state, text) do
	{state, @ctrl.send_message(state.message.chat, text)}
      end
    end
  end
end
