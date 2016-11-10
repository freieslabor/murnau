defmodule Murnau.Adapter.Telegram.Chat.Simple do
  use Murnau.Adapter.Telegram.Chat.Base
  require Logger

  @commands %{"help" => :help, "timer" => :timer, "kill" => :kill}

  def start_link(msg, id) do
    GenServer.start_link(__MODULE__, %{message: msg},
      [name: {:global, {:chat, id}}, debug: [:trace, :statistics]])
  end

  def init(state) do
#    Process.flag(:trap_exit, true)
    Logger.debug "#{__MODULE__}.init"

    IO.inspect state

    state = set_commands(state, @commands)

    say(state, "Morgähn!")
    {:ok, state}
  end

  def handle_cast(:help, state) do
    say(state, "AAAaaargghh! Ich stöörbe")

    {:noreply, state}
  end

  defp unknown_command(state) do
    say(state, "Sprichst du mit mir?!")
    help(state)
  end

  def kill(state) do
    Process.exit(self, :kill)
    {state, {:ok, []}}
  end

  def help(state) do
    say(state, "Ich versteh nur:")
    Enum.map(state.commands, fn{k,v} -> say(state, "/#{k}") end)
    {state, {:ok, []}}
  end

  def timer(state) do
    {:ok, pid} = Murnau.Timeout.start_link(self)
    Murnau.Timeout.register(pid, :help)
    Murnau.Timeout.rewind(pid, fn(p) -> true end, 50)

    {state, {:ok, []}}
  end
end
