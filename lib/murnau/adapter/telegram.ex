defmodule Murnau.Adapter.Telegram do
  @moduledoc """
  Genserver that handles all updates from the Telegram server.
  """
  alias Murnau.Adapter.Telegram.Api, as: Api
  require Logger
  require IEx
  use GenServer

  @vsn "0"
  @chat_id Application.get_env(:murnau, :labor_chat_id)

  def start_link() do
    GenServer.start_link(__MODULE__, %{id: 1}, name: __MODULE__)
  end

  def accept() do
    Process.send(__MODULE__, :accept, [])
  end

  def stop(), do: GenServer.stop(__MODULE__)

  def init(state) do
    accept
    {:ok, state}
  end

  def handle_info(:accept, state) do
    state.id
    |> Api.getupdate
    |> do_accept(state)
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    Logger.debug "#{__MODULE__}.handle_info: go down"
    {:noreply, state}
  end

  defp try_cast(chat_id, message) do
    case GenServer.whereis({:global, {:chat, chat_id}}) do
      nil -> {:error, :invalid_chat}
      chat -> GenServer.cast(chat, message)
    end
  end

  defp do_accept({:ok, nil}, state) do
    Process.send_after(self(), :accept, 1000)
    {:noreply, state}
  end
  defp do_accept({:ok, msg}, state) do
    try_cast @chat_id, {:accept, msg}
    Process.send_after(self(), :accept, 1000)
    {:noreply, Map.put(state, :id, msg.update_id + 1)}
  end
  defp do_accept({:forbidden, []}, _id, _state) do
    stop
  end
end
