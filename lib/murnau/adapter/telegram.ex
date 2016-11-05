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

  def start_room(msg) do
    Murnau.Adapter.Telegram.Supervisor.start_chat(msg)
  end

  def stop(), do: GenServer.stop(__MODULE__)

  def init(state) do
    Murnau.Adapter.Telegram.Supervisor.start_link
    accept
    {:ok, state}
  end

  def handle_info(:accept, state) do
    state.id
    |> Api.getupdate
    |> do_accept(state)
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {:noreply, state}
  end

  defp try_cast({cmd, req}) do
    chat_id = req.message.chat.id

    case GenServer.whereis({:global, {:chat, chat_id}}) do
      nil -> start_room(req)
      chat -> GenServer.cast(chat, {cmd, req})
    end
  end

  defp do_accept({:ok, nil}, state) do
    Process.send_after(self(), :accept, 1000)
    {:noreply, state}
  end
  defp do_accept({:ok, req}, state) do
    try_cast {:accept, req}
    Process.send_after(self(), :accept, 1000)
    {:noreply, Map.put(state, :id, req.update_id + 1)}
  end
  defp do_accept({:forbidden, []}, _id, _state) do
    stop
  end
end
