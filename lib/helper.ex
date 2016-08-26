defmodule Murnau.Helper do
  @moduledoc """
  Provides helper functions for Murnau.
  """
  def nearest_match(map, s) do
    try do
      map
      |> Enum.map(fn{k, v} -> {String.jaro_distance(k, s), k, v} end)
      |> Enum.filter(fn({j, _, _}) -> j > 0.7 end)
      |> Enum.max
      |> Tuple.delete_at(0)
      |> Tuple.delete_at(0)
      |> Tuple.insert_at(0, :okay)
    rescue
      e in Enum.EmptyError -> {:error, nil}
    end
  end
end
 
