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
    IO.puts("Auth Token: #{token}")
    IO.puts("\nUpdate these settings using `devito config --apiurl <APIURL> --authtoken <TOKEN>")
  end

  defp run({parsed, ["config"], _errors}) do
    apiurl = Keyword.get(parsed, :apiurl)
    authtoken = Keyword.get(parsed, :authtoken)

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

  defp run({[url], _flags, _errors}) do
    case DevitoCLI.HTTPClient.post(url: url) do
      {:ok, 200, _resp, _ref} -> :ok
      _ -> :error
    end
  end

  defp run({[url, short_code], _flags, _errors}) do
    case DevitoCLI.HTTPClient.post(url: url, short_code: short_code) do
      {:ok, 200, _resp, _ref} -> :ok
      _ -> :error
    end
  end

  defp run(_) do
    IO.puts("Valid commands are:")
    IO.puts("`devito config --apiurl <APIURL> --authtoken <TOKEN>`")
    IO.puts("`devito URL`")
    IO.puts("`devito URL SHORT_CODE`")
  end
end
