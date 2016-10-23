defmodule Murnau.Adapter.LaborTest do
  alias Murnau.Adapter.Labor
  use ExUnit.Case, async: true
  require Logger

  setup do
    {:ok, server} = Murnau.Labor.HTTPTest.start_link
    {:ok, server: server}
  end

  test "close command is supported" do
    {:ok, pid} = Labor.start_link(0)
    commands = Murnau.Adapter.Labor.commands(pid)
    valid = Map.has_key?(commands, "close")
    assert valid == true
  end

  test "open command is supported" do
    {:ok, pid} = Labor.start_link(1)
    commands = Murnau.Adapter.Labor.commands(pid)
    valid = Map.has_key?(commands, "open")
    assert valid == true
  end

  test "handle :accept" do
    {:ok, labor} = Labor.start_link(2)
    msg = %Murnau.Adapter.Telegram.Message{text: "/open"}
    update = %Murnau.Adapter.Telegram.Update{message: msg}
    GenServer.cast(labor, {:accept, update})
  end

  test "handle broken update" do
    {:ok, labor} = Labor.start_link(3)
    update = %Murnau.Adapter.Telegram.Update{message: nil}
    GenServer.cast(labor, {:accept, update})
  end

  test "ignore wrong chat" do
    {:ok, labor} = Labor.start_link(4)
    chat = %Murnau.Adapter.Telegram.Chat{id: 9}
    msg = %Murnau.Adapter.Telegram.Message{text: "/open", chat: chat}
    update = %Murnau.Adapter.Telegram.Update{message: msg}
    Labor.accept(labor, update)
    :timer.sleep 1000
    assert Murnau.Labor.HTTPTest.open? == false
  end

  test "handle /open and /close", %{server: server} do
    {:ok, labor} = Labor.start_link(4)
    chat = %Murnau.Adapter.Telegram.Chat{id: 4}
    msg = %Murnau.Adapter.Telegram.Message{text: "/open", chat: chat}
    update = %Murnau.Adapter.Telegram.Update{message: msg}
    Labor.accept(labor, update)
    :timer.sleep 1000
    assert Murnau.Labor.HTTPTest.open? == true

    msg = %Murnau.Adapter.Telegram.Message{text: "/close", chat: chat}
    update = %Murnau.Adapter.Telegram.Update{message: msg}
    Labor.accept(labor, update)
    :timer.sleep 1000
    assert Murnau.Labor.HTTPTest.open? == false
  end
end
