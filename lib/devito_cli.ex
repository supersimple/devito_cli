defmodule DevitoCLI do
  @moduledoc """
  Documentation for `DevitoCLI`
  """

  alias DevitoCLI.Config

  def main(argv) do
    argv
    |> OptionParser.parse(strict: [apiurl: :string, authtoken: :string])
    |> run()
  end

  # with no parsed options, read the config
  defp run({[], ["config"], _errors}) do
    url = Config.get(:api_url)
    token = Config.get(:auth_token)
    IO.puts("API URL: #{url}")
    IO.puts("Auth Token: #{inspect(token)}")
    IO.puts("\nUpdate these settings using `devito config --apiurl <APIURL> --authtoken <TOKEN>")
  end

  defp run({parsed, ["config"], _errors}) do
    apiurl = Keyword.get(parsed, :apiurl)
    authtoken = Keyword.get(parsed, :authtoken) |> hash_token()

    case Config.write(api_url: apiurl, auth_token: authtoken) do
      :ok ->
        IO.puts("Your config was updated")

      _ ->
        IO.puts(
          "An error occurred." <>
            "\nUpdate these settings using `devito config --apiurl <APIURL> --authtoken <TOKEN>`"
        )
    end
  end

  defp run({_parsed, [url], _errors}) do
    case DevitoCLI.HTTPClient.post("api/link", url: url) do
      :error -> :error
      body -> show_short_code(body)
    end
  end

  defp run({_parsed, [url, short_code], _errors}) do
    case DevitoCLI.HTTPClient.post("api/link", url: url, short_code: short_code) do
      :error -> :error
      body -> show_short_code(body)
    end
  end

  defp run(_) do
    IO.puts("Valid commands are:")
    IO.puts("`devito config --apiurl <APIURL> --authtoken <TOKEN>`")
    IO.puts("`devito URL`")
    IO.puts("`devito URL SHORT_CODE`")
  end

  defp show_short_code(json) do
    with {:ok, decoded} <- Jason.decode(json),
         short_code <- Map.get(decoded, "short_code"),
         api_url <- Config.get(:api_url) do
      URI.merge(api_url, short_code) |> to_string() |> IO.puts()
    else
      _ -> IO.puts("Link was created")
    end
  end

  defp hash_token(token) do
    :sha256
    |> :crypto.hash(token)
    |> Base.encode64()
  end
end
