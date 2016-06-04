defmodule Murnau do
  @moduledoc """
  Murnau Application. Supervises the labor and ctrl adapter.
  """
  use Application

  @vsn "0"
  @ctrl_adapter Application.get_env(:murnau, :ctrl_adapter)
  @labor_adapter Application.get_env(:murnau, :labor_adapter)

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(@labor_adapter, [], [restart: :temporary, id: make_ref]),
      worker(@ctrl_adapter, [], [restart: :temporary, id: make_ref]),
    ]

    opts = [strategy: :one_for_one, name: Murnau.Supervisor]
    Supervisor.start_link(children, opts)

    accept
  end

  def accept() do
    @ctrl_adapter.start_link
  end
end
