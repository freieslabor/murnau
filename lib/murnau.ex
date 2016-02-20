defmodule Murnau do
  require Logger
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Logger.debug "#{__MODULE__}.start"

    children = [
      worker(Task, [Murnau.Telegram, :accept, [0]]),
    ]

    opts = [strategy: :one_for_one, name: Murnau.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
