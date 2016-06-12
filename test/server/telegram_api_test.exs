defmodule Murnau.Server.Telegram.ApiTest do
  use ExUnit.Case, async: true
  doctest Murnau
  require Logger

  test "getUpdate returns correct command" do
    assert {:ok, %{message: %{text: "/close"}, update_id: 1}} = Murnau.Adapter.Telegram.Api.getupdate(1)
    assert {:ok, %{message: %{text: "/open"}, update_id: 2}} = Murnau.Adapter.Telegram.Api.getupdate(2)
  end

  test "getUpdate handles non-JSON" do
    assert {:error, []} = Murnau.Adapter.Telegram.Api.getupdate(0)
  end
end
