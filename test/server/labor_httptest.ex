defmodule Murnau.Labor.HTTPTest do
  @url "https://freiestestlabor.org/api/"

  require Logger

  def start_link do
    Agent.start_link(fn -> %{open: false} end, name: __MODULE__)
  end

  def open() do
    Agent.update(__MODULE__,
      fn map -> Map.update(map, :open, true, fn(_) -> true end) end)
  end
  def close() do
    Agent.update(__MODULE__,
      fn map -> Map.update(map, :open, false, fn(_) -> false end) end)
  end
  def open?() do
    Agent.get(__MODULE__, fn map -> map[:open] end)
  end

  def get!(@url <> "room") do
    {:ok, %HTTPoison.Response{status_code: 200, body: room}}
  end

  def post(@url <> "room", {:form, form}, _, _) do
    Logger.debug "post request"
    if form[:open] == 1 do
      open
    else
      close
    end
    {:ok, %HTTPoison.Response{status_code: 200,
                              body: room}}
  end

  defp room() do
    "{\"since\": 1466209355, \"open\": #{open?}}"
  end
end
