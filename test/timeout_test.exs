defmodule Murnau.TimeoutTest do
  use ExUnit.Case, async: true
  require Logger

  defp always_open(), do: true

  test "timer can be started" do
    {:ok, pid} = Murnau.Timeout.start_link(self())
    Murnau.Timeout.rewind(pid, &always_open/0, 10)
    assert true == Process.alive?(pid)
  end

  test "timer can be stopped" do
    {:ok, pid} = Murnau.Timeout.start_link(self())
    Murnau.Timeout.rewind(pid, &always_open/0, 1000)
    Murnau.Timeout.stop(pid)
    assert false == Process.alive?(pid)
  end

  test "timer issues heartbeats" do
    {:ok, pid} = Murnau.Timeout.start_link(self())
    Murnau.Timeout.rewind(pid, &always_open/0, 1000, 500)
    :timer.sleep 3000
    stats = Murnau.Timeout.statistics(pid)
    assert stats.beats == 4
    Murnau.Timeout.stop(pid)
  end

  test "timer checks condition" do
    {:ok, server} = Test.Server.start_link
    {:ok, pid} = Murnau.Timeout.start_link(server)
    Murnau.Timeout.rewind(pid, &Test.Server.is_open/1, 1000, 500)
    :timer.sleep 2000
    {:ok, beats} = Test.Server.get_beats(server)
    assert beats == 2
    Murnau.Timeout.stop(pid)
  end

  test "timer sends alarm" do
    {:ok, server} = Test.Server.start_link
    {:ok, pid} = Murnau.Timeout.start_link(server)
    Murnau.Timeout.register(pid, :close)
    Murnau.Timeout.rewind(pid, &Test.Server.is_open/1, 1000, 500)
    :timer.sleep 5000
    assert Test.Server.is_open(server) == false
    Murnau.Timeout.stop(pid)
    Test.Server.stop(server)
  end
end
