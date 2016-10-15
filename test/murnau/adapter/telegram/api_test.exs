defmodule Murnau.Server.Telegram.ApiTest do
  alias Murnau.Adapter.Telegram.Api
  alias Murnau.Adapter.Telegram
  use ExUnit.Case, async: true
  doctest Murnau
  require Logger

  test "getUpdate handles close" do
    assert {:ok, %{message: %{text: "/close"}, update_id: 1}} = Api.getupdate(9001)
  end
  test "getUpdate handles open" do
    assert {:ok, %{message: %{text: "/open"}, update_id: 2}} = Api.getupdate(9002)
  end
  test "getUpdate handles room" do
    assert {:ok, %{message: %{text: "/room"}, update_id: 3}} = Api.getupdate(9003)
  end
  test "getUpdate handles broken response" do
    assert {:error, %Poison.SyntaxError{message: "Unexpected end of input"}} = Api.getupdate(9004)
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
  test "getUpdate handles unknown values with error" do
    for val <- 500..600 do
      assert {:error, nil} = Api.getupdate(val)
    end
    assert {:ok, %{message: %{text: "/close"}, update_id: 1}} = Api.getupdate(9001)
  end
  test "sendMessage returns correct response" do
    chat = %Telegram.Chat{id: 9}
    assert {:ok, %{text: "foobar"}} = Api.send_message(chat ,"foobar")
  end
  test "editMessage returns correct response" do
    msg = %Telegram.Message{chat: %Telegram.Chat{id: 9}, text: "foobar"}

    assert {:ok, %{text: "frob"}} = Api.edit_message(msg, "frob")
  end
end
