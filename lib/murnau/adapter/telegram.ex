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
    Logger.debug "#{__MODULE__}.start_link()"
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    Logger.debug "#{__MODULE__}.init()"
    Task.start(fn -> accept end)
  end

  defp try_call(chat_id, message) do
    case GenServer.whereis({:global, {:chat, chat_id}}) do
      nil -> {:error, :invalid_chat}
      chat -> GenServer.call(chat, message)
    end
  end

  defp try_cast(chat_id, message) do
    case GenServer.whereis({:global, {:chat, chat_id}}) do
      nil -> {:error, :invalid_chat}
      chat -> GenServer.cast(chat, message)
    end
  end

  def accept(id \\ 1) do
    case id |> Api.getupdate |> do_accept(id) do
      {:stop, _} -> nil
      {_, id} -> accept(id)
    end
  end

  defp do_accept({:ok, nil}, id) do
    :timer.sleep(1000)
    {:again, id}
  end
  defp do_accept({:error, :timeout}, id) do
    Logger.debug "#{__MODULE__}.accept: Timedout"
    {:again, id}
  end
  defp do_accept({:error, _}, id) do
    :timer.sleep(1000)
    {:ok, id}
  end
  defp do_accept({:ok, msg}, _id) do
    try_cast @chat_id, {:accept, msg}
    {:ok, msg.update_id + 1}
  end
  defp do_accept({:forbidden, []}, _id) do
    Logger.debug "#{__MODULE__}.accept: Forbidden"
    {:stop, nil}
  end
  defp do_accept({:conflict, []}, _id) do
    Logger.debug "#{__MODULE__}.accept: Conflict"
    {:stop, nil}
  end
end
