defmodule Murnau.Adapter.Labor.ApiTest do
  alias Murnau.Adapter.Labor.Api
  use ExUnit.Case, async: true
  require Logger

  test "room can be opened" do
    Murnau.Labor.HTTPTest.start_link
    Api.room_open
    assert Api.room_is_open? == true
  end
  test "room can be closed" do
    Murnau.Labor.HTTPTest.start_link
    Api.room_close
    assert Api.room_is_open? == false
  end
end
