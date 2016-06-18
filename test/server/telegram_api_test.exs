defmodule Murnau.Server.Telegram.ApiTest do
  alias Murnau.Adapter.Telegram.Api
  alias Murnau.Adapter.Telegram
  use ExUnit.Case, async: true
  doctest Murnau
  require Logger

  test "getUpdate returns correct command" do
    assert {:ok, %{message: %{text: "/close"}, update_id: 1}} = Api.getupdate(1)
    assert {:ok, %{message: %{text: "/open"}, update_id: 2}} = Api.getupdate(2)
  end

  test "getUpdate handles non-JSON" do
    assert {:error, []} = Api.getupdate(0)
  end

  test "getUpdate handles 403" do
    assert {:forbidden, []} = Api.getupdate(403)
  end
  test "getUpdate handles 409" do
    assert {:conflict, []} = Api.getupdate(409)
  end
  test "sendMessage returns correct response" do
    chat = %Telegram.Chat{id: 9}
    assert {:ok, %{text: "foobar"}} = Api.send_message(chat ,"foobar")
  end
end
