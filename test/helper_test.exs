defmodule HelperTest do
  use ExUnit.Case, async: true
  doctest Murnau
  require Logger

  test "nearest_match" do
    map = %{"open" => 1, "close" => 2}
    s1 = "open"
    s2 = "ope"
    s3 = "opened"
    s4 = "close"
    s5 = "cose"
    s6 = "closed"
    s7 = "foobar"
    s8 = "me"
    s9 = "me roger"

    assert Murnau.Helper.nearest_match(map, s1) == {:okay, 1}
    assert Murnau.Helper.nearest_match(map, s2) == {:okay, 1}
    assert Murnau.Helper.nearest_match(map, s3) == {:okay, 1}
    assert Murnau.Helper.nearest_match(map, s4) == {:okay, 2}
    assert Murnau.Helper.nearest_match(map, s5) == {:okay, 2}
    assert Murnau.Helper.nearest_match(map, s6) == {:okay, 2}
    assert Murnau.Helper.nearest_match(map, s7) == {:error, %Enum.EmptyError{message: "empty error"}}
    assert Murnau.Helper.nearest_match(map, s8) == {:error, %Enum.EmptyError{message: "empty error"}}
    assert Murnau.Helper.nearest_match(map, s9) == {:error, %Enum.EmptyError{message: "empty error"}}
  end
end
