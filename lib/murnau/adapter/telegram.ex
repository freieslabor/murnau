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
    case Api.getupdate(id) do
      {:ok, nil} ->
        :timer.sleep(1000)
        accept(id)
      {:ok, msg} ->
        try_cast @chat_id, {:accept, msg}
        accept(msg.update_id + 1)
      {:error, :timeout} ->
        Logger.debug "#{__MODULE__}.accept: Timedout"
        accept(id)
      {:forbidden, []} ->
        Logger.debug "#{__MODULE__}.accept: Forbidden"
      {:conflict, []} ->
        Logger.debug "#{__MODULE__}.accept: Conflict"
      {:error, _} ->
        :timer.sleep(1000)
        accept(id)
    end
  end

end
