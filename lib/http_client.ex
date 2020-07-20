defmodule DevitoCLI.HTTPClient do
  @moduledoc """
  Handles all HTTP requests for the application.
  """

  alias DevitoCLI.Config

  def post(body) do
    Config.get(:url)
    # "https://hex.pm",
    # {:form, [url: "foo", short_code: "bar", auth_token: ""]}

    # :hackney.request(:post, url, [], body, [])
  end
end
