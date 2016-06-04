defmodule MurnauTest do
  use ExUnit.Case, async: false
  doctest Murnau
  require Logger

  # defmodule Server.Telegram do
  #   use Plug.Router
  #   plug Plug.Logger
  #
  #   plug :match
  #   plug :dispatch
  #
  #   @token Application.get_env(:murnau, :telegram_token)
  #   @responses ["/open", "/close", "/closed", "/opened", "/open", "/nepo"]
  #
  #   get "/bot:token/getUpdates" do
  #     conn = fetch_query_params(conn)
  #     %{"offset" => offset} = conn.params
  #     offset = String.to_integer(offset)
  #     send_resp(conn, 403, "Permission denied: token #{token}!=#{@token} offset #{offset} > 2")
  #   end
  #
  #   match _ do
  #     send_resp(conn, 404, "oops")
  #     conn
  #   end
  # end
  #
  # setup do
  #   {:ok, pid} = Plug.Adapters.Cowboy.http Server.Telegram, [], port: 4000
  #   {:ok, pid: pid}
  # end
  #
  # test "Murnau starts and accepts request" do
  #   {:ok, client} = Murnau.accept
  #   :timer.sleep(2000)
  # end
end
