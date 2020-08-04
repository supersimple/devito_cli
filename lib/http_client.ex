defmodule DevitoCLI.HTTPClient do
  @moduledoc """
  Handles all HTTP requests for the application.
  """

  alias DevitoCLI.Config

  def get(path, params \\ []) do
    api_url =
      :api_url
      |> Config.get()
      |> URI.merge(path)
      |> to_string()

    auth_token = Config.get(:auth_token)

    params =
      Keyword.merge([auth_token: auth_token], params)
      |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
      |> Enum.join("&")

    :hackney.request(:get, api_url <> "?#{params}")
    |> respond()
  end

  def post(path, body) do
    api_url =
      :api_url
      |> Config.get()
      |> URI.merge(path)
      |> to_string()

    auth_token = Config.get(:auth_token)
    body = Keyword.put(body, :auth_token, auth_token)

    :hackney.request(:post, api_url, [], {:form, body}, [])
    |> respond()
  end

  defp respond({:ok, 201, _resp_hdr, ref}) do
    {:ok, body} = :hackney.body(ref)
    body
  end

  defp respond({:ok, 200, _resp_hdr, ref}) do
    {:ok, body} = :hackney.body(ref)
    body
  end

  defp respond(_), do: :error
end
