defmodule Murnau.Adapter.Adapter do
  @moduledoc """
  Define the protocol an adapter must support.
  """
  @callback get_response() :: any
end
