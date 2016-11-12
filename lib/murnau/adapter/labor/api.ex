defmodule Murnau.Adapter.Labor.Api do
  @moduledoc """
  Provides API calls to the Labor-API.
  """
  require Logger
  use GenServer

  @url Application.get_env(:murnau, :labor_url)
  @token Application.get_env(:murnau, :labor_token)
  @user Application.get_env(:murnau, :labor_user)
  @laborcam Application.get_env(:murnau, :labor_cam_url)

  case Mix.env do
    :prod -> @httpclient HTTPoison
    :dev -> @httpclient HTTPoison
    _ -> @httpclient Murnau.Labor.HTTPTest
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def room_is_open?(_caller), do: GenServer.call(__MODULE__, :is_open)
  def room_open(), do: GenServer.cast(__MODULE__, {:room, 1})
  def room_close(), do: GenServer.cast(__MODULE__, {:room, 0})

  def init(state) do
    {:ok, Map.put(state, :open, false)}
  end

  def handle_call(:is_open, _from, state) do
    result = "room"
    |> process_url
    |> @httpclient.get
    |> response

    state = Map.put(state, :open, result[:open])

    {:reply, result[:open], state}
  end

  def handle_cast({:room, open?}, state) do
    auth = [hackney: [basic_auth: {@user, @token}]]

    "room"
    |> process_url
    |> @httpclient.post({:form, [open: open?]}, %{}, auth)
    |> response

    state = Map.put(state, :open, open? == 1)

    {:noreply, state}
  end

  defp response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    process_response_body(body)
  end

  defp process_url(method) do
    "#{@url}/api/" <> method
  end

  def cam_fetch() do
    %HTTPoison.Response{body: body} = @httpclient.get!(@laborcam)
    File.write!(laborcam_current, body)
  end

  defp process_response_body(body) do
    body
    |> Poison.decode!
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

  def laborcam_current, do: "/tmp/webcam.jpg"
end
