defmodule Murnau.Adapter.Labor.ApiTest do
  alias Murnau.Adapter.Labor.Api
  use ExUnit.Case, async: true
  require Logger

  test "room can be opened" do
    {:ok, pid} = Murnau.Labor.HTTPTest.start_link
    Api.room_open
    assert Api.room_is_open? == true
    Process.exit(pid, :kill)
  end
  test "room can be closed" do
    {:ok, pid} = Murnau.Labor.HTTPTest.start_link
    Api.room_close
    assert Api.room_is_open? == false
    Process.exit(pid, :kill)
  end
end
