defmodule Murnau.Adapter.Telegram.Supervisor do
  use Supervisor
  require Logger

  def start_link do
    Logger.debug "#{__MODULE__}.start_link"
    Supervisor.start_link(__MODULE__, [], [name: __MODULE__, debug: [:trace, :statistics]])
  end

  def start_chat(msg) do
    Logger.debug "#{__MODULE__}.start_chat"
    Supervisor.start_child(__MODULE__, [msg])
  end

  def init(_) do
    children = [
      worker(Murnau.Chat, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
