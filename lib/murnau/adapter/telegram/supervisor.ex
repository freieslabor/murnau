defmodule Murnau.Adapter.Telegram.Supervisor do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, [],
      [name: :telegram_sup, debug: [:trace, :statistics]])
  end

  def start_chat(type, message, id) do
    Logger.debug "#{__MODULE__}.start_chat: #{type}"
    child =
      worker(type, [message, id], [])

    Supervisor.start_child(:telegram_sup, child)
  end

  def init(_) do
    supervise([], strategy: :one_for_one)
  end
end
