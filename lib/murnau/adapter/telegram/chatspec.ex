defmodule Murnau.Adapter.Telegram.ChatSpec do
  @callback start_link(Murnau.Adapter.Telegram.Message.t, Number) :: any
  @callback init(Map.t) :: any
end
