defmodule Murnau.Adapter.Labor.Api do
  @moduledoc """
  Provides API calls to the Labor-API.
  """
  use HTTPoison.Base
  require Logger

  @url Application.get_env(:murnau, :labor_url)
  @token Application.get_env(:murnau, :labor_token)
  @user Application.get_env(:murnau, :labor_user)
  @laborcam Application.get_env(:murnau, :labor_cam_url)
  @env Mix.env

  def process_url(method) do
    "#{@url}/api/" <> method
  end

  def room_is_open?(), do: get!("room").body[:open]

  def room_open() do
    auth = [hackney: [basic_auth: {@user, @token}]]
    post("room", {:form, [open: 1]}, %{}, auth)
  end

  def room_close() do
    auth = [hackney: [basic_auth: {@user, @token}]]
    post("room", {:form, [open: 0]}, %{}, auth)
  end

  def cam_fetch() do
    %HTTPoison.Response{body: body} = HTTPoison.get!(@laborcam)
    File.write!(laborcam_current, body)
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

  def laborcam_current, do: "/tmp/webcam.jpg"
end
