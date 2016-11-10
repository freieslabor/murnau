defmodule Murnau.Adapter.Telegram.Chat do
  @callback start_link(Murnau.Adapter.Telegram.Message.t, Number) :: any
  @callback init(Map.t) :: any
end
