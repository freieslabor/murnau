defmodule Murnau.Adapter.Labor.Api do
  @moduledoc """
  Provides API calls to the Labor-API.
  """
  require Logger

  @url Application.get_env(:murnau, :labor_url)
  @token Application.get_env(:murnau, :labor_token)
  @user Application.get_env(:murnau, :labor_user)
  @laborcam Application.get_env(:murnau, :labor_cam_url)

  case Mix.env do
    :prod -> @httpclient HTTPoison
    :dev -> @httpclient HTTPoison
    _ -> @httpclient Murnau.Labor.HTTPTest
  end

  defp response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    process_response_body(body)
  end

  defp process_url(method) do
    "#{@url}/api/" <> method
  end

  def room_is_open?() do
    result = "room"
    |> process_url
    |> @httpclient.get
    |> response

    result[:open]
  end

  def room_open() do
    auth = [hackney: [basic_auth: {@user, @token}]]

    "room"
    |> process_url
    |> @httpclient.post({:form, [open: 1]}, %{}, auth)
    |> response
  end

  def room_close() do
    auth = [hackney: [basic_auth: {@user, @token}]]

    "room"
    |> process_url
    |> @httpclient.post({:form, [open: 0]}, %{}, auth)
    |> response
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
