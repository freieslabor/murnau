defmodule Murnau.Telegram.HTTPTest do
  require Logger
  @url "https://api.testlegram.org/bot1234/"
  @params "?timeout=5&offset="

  def get(@url <> "getUpdates" <> @params <> "0" <> _, [], _) do
    {:ok, %HTTPoison.Response{body: "<html></html>",
                              status_code: 200,
                              headers: header("text/html")}}
  end
  def get(@url <> "getUpdates" <> @params <> "9001" <> _, [], _) do
    {:ok, %HTTPoison.Response{body: bot_command("1", "close"),
                              status_code: 200,
                              headers: header("application/json")}}
  end
  def get(@url <> "getUpdates" <> @params <> "9002" <> _, [], _) do
    {:ok, %HTTPoison.Response{body: bot_command("2", "open"),
                              status_code: 200,
                              headers: header("application/json")}}
  end
  def get(@url <> "getUpdates" <> @params <> "9003" <> _, [], _) do
    {:ok, %HTTPoison.Response{body: bot_command("3", "room"),
                              status_code: 200,
                              headers: header("application/json")}}
  end
  def get(@url <> "getUpdates" <> @params <> "9004" <> _, [], _) do
    {:ok, %HTTPoison.Response{body: broken_bot_command("4", "open"),
                              status_code: 200,
                              headers: header("application/json")}}
  end
  def get(@url <> "getUpdates" <> @params <> val, [], _) do
    [code, _] = String.split(val, "&")
    {:ok, %HTTPoison.Response{status_code: String.to_integer(code),
                              headers: header("text/html")}}
  end

  def get(@url <> "getMe", [], _) do
    {:ok, %HTTPoison.Response{body: bot_command("1", "close"),
                              status_code: 200,
                              headers: header("application/json")}}
  end

  def post(@url <> "sendMessage", {:form, form}, _) do
    id = form[:chat_id]
    case id do
      23 ->
	{:ok, %HTTPoison.Response{status_code: 200,
				  body: broken_send_response("broken"),
				  headers: header("application/json")}}
      9 ->
	{:ok, %HTTPoison.Response{status_code: 200,
				  body: send_response(form[:text]),
				  headers: header("application/json")}}
      _ ->
	{:ok, %HTTPoison.Response{status_code: 200,
				  body: send_response(form[:text]),
				  headers: header("application/json")}}
    end
  end

  def post(@url <> "editMessageText", {:form, form}, _) do
    {:ok, %HTTPoison.Response{status_code: 200,
                              body: send_response(form[:text]),
                              headers: header("application/json")}}
  end

  defp header(type) do
    [{"Server", "nginx/1.10.0"},
     {"Date", "Sun, 05 Jun 2016 15:21:49 GMT"},
     {"Content-Type", type},
     {"Content-Length", "84"},
     {"Connection", "keep-alive"},
     {"Access-Control-Allow-Origin", "*"},
     {"Access-Control-Allow-Methods", "GET, POST, OPTIONS"},
     {"Access-Control-Expose-Headers",
      "Content-Length,Content-Type,Date,Server,Connection"},
     {"Strict-Transport-Security", "max-age=31536000; includeSubdomains"}]
  end

  defp send_response(text) do
    "{\"ok\":true,\"result\":[{\"text\":\"" <> text <> "\"}]}"
  end

  defp broken_send_response(text) do
    "{\"ok\":true,\"result\":[{\"text\":\"" <> text <> "\"}"
  end

  defp bot_command(id, cmd) do
    "{\"ok\":true,\"result\":[{\"update_id\":" <> id <> ",\n\"message\":{\"message_id\":2614,\"from\":{\"id\":9,\"first_name\":\"Johnny\",\"username\":\"dude\"},\"chat\":{\"id\":9,\"first_name\":\"Johnny\",\"username\":\"dude\",\"type\":\"private\"},\"date\":1465663560,\"text\":\"\\/" <> cmd <> "\",\"entities\":[{\"type\":\"bot_command\",\"offset\":0,\"length\":6}]}}]}"
  end

  defp broken_bot_command(id, cmd) do
    "{\"ok\":true,\"result\":[{\"update_id\":" <> id <> ",\n\"message\":{\"message_id\":2614,\"from\":{\"id\":9,\"first_name\":\"Johnny\",\"username\":\"dude\"},\"chat\":{\"id\":9,\"first_name\":\"Johnny\",\"username\":\"dude\",\"type\":\"private\"},\"date\":1465663560,\"text\":\"\\/" <> cmd <> "\",\"entities\":[{\"type\":\"bot_command\",\"offset\":0,\"length\":6}]}}]"
  end
end
