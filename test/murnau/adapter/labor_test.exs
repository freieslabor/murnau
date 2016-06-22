defmodule Murnau.Adapter.LaborTest do
  alias Murnau.Adapter.Labor
  use ExUnit.Case, async: true
  require Logger

  test "close command is supported" do
    {:ok, pid} = Labor.start_link
    commands = GenServer.call(pid, {:commands})
    valid = Map.has_key?(commands, "close")
    assert valid = true
  end

  test "open command is supported" do
    {:ok, pid} = Labor.start_link
    commands = GenServer.call(pid, {:commands})
    valid = Map.has_key?(commands, "open")
    assert valid = true
  end

end
