defmodule Murnau.Server.Telegram.ApiTest do
  use ExUnit.Case, async: false
  doctest Murnau
  require Logger

  test "getUpdate returns correct command" do
    assert {:ok, %{message: %{text: "/close"}, update_id: 1}} = Murnau.Adapter.Telegram.Api.getupdate(1)
    assert {:ok, %{message: %{text: "/open"}, update_id: 2}} = Murnau.Adapter.Telegram.Api.getupdate(2)
  end
end
