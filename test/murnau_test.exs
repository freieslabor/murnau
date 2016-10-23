defmodule MurnauTest do
  use ExUnit.Case, async: false
  doctest Murnau
  require Logger

  # defmodule Server.Telegram do
  #   @token Application.get_env(:murnau, :telegram_token)
  #   @responses ["/open", "/close", "/closed", "/opened", "/open", "/nepo"]
  #
  # test "Murnau starts and accepts request" do
  #   {:ok, client} = Murnau.accept
  #   :timer.sleep(2000)
  # end
end
