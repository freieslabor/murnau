defmodule Murnau.Adapter.Telegram.Api do
  @moduledoc """
  Provides API calls to the Telegram server. Returns only the body of the response.
  """

  use HTTPoison.Base
  require Logger

  @vsn "0"
  @url Application.get_env(:murnau, :telegram_url)
  @token Application.get_env(:murnau, :telegram_token)
  @port Application.get_env(:murnau, :ctrl_port)

  defp response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, body}
  end
  defp response({:ok, %HTTPoison.Response{status_code: 403}}) do
    Logger.debug "#{__MODULE__}: flush queue"
    {:forbidden, []}
  end
  defp response({:ok, %HTTPoison.Response{status_code: 409}}) do
    {:conflict, []}
  end
  defp response({:ok, %HTTPoison.Response{status_code: _}, body: body}) do
    IO.inspect body
    {:ok, body}
  end
  defp response({:error, %HTTPoison.Error{reason: reason}}) do
    IO.inspect reason
    {:error, reason}
  end

  def getupdate(offset, limit \\ 100, timeout \\ 5,
        opts \\ [timeout: :infinity, recv_timeout: :infinity]) do
    Logger.debug "#{__MODULE__}: getUpdates?timeout=#{timeout}&offset=#{offset}&limit=#{limit}"

    "getUpdates?timeout=#{timeout}&offset=#{offset}&limit=#{limit}"
    |> get([], opts)
    |> response
  end

  def send_message(chat, msg, keyboard \\ nil, opts \\ %{"Content-type" => "application/x-www-form-urlencoded"}) do
    form = [chat_id: chat.id, text: msg]
    if keyboard do
      form = form ++ [reply_markup: keyboard]
    end

    "sendMessage"
    |> post({:form, form}, opts)
    |> response
  end

  def edit_message(msg, text, opts \\ %{"Content-type" => "application/x-www-form-urlencoded"}) do
    Logger.debug "#{__MODULE__}: edit_message(#{msg.chat.id}, #{msg.message_id}, #{text})"
    form = [chat_id: msg.chat.id, message_id: msg.message_id, text: text]

    "editMessageText"
    |> post({:form, form}, opts)
    |> response
  end

  def process_url(method) do
    Logger.debug "#{__MODULE__}: process_url => #{@url}"
    "#{@url}/bot#{@token}/" <> method
  end

  def process_response_body(body) do
    Logger.debug "#{__MODULE__}: process_response_body"
    result = body
    |> Poison.decode!(keys: :atoms)
    |> Map.get(:result)

    if is_list result do
      List.first result
    else
      result
    end
  end
end
