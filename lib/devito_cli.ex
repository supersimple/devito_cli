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

  # get info about all links
  defp run({[], ["info"], _errors}) do
    case DevitoCLI.HTTPClient.get("api/") do
      :error -> IO.puts("There was an error while trying to find the links")
      body -> show_list_table(body)
    end
  end

  # get info about a link
  defp run({[], ["info", short_code], _errors}) do
    case DevitoCLI.HTTPClient.get("api/#{short_code}") do
      :error -> IO.puts("There was an error while trying to find the link")
      body -> show_link(body)
    end
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
      :error -> IO.puts("There was an error while trying to create your link")
      body -> show_short_code(body)
    end
  end

  defp run({_parsed, [url, short_code], _errors}) do
    case DevitoCLI.HTTPClient.post("api/link", url: url, short_code: short_code) do
      :error -> IO.puts("There was an error while trying to create your link")
      body -> show_short_code(body)
    end
  end

  defp run(_) do
    IO.puts("Valid commands are:")
    IO.puts("`devito config --apiurl <APIURL> --authtoken <TOKEN>`")
    IO.puts("`devito URL`")
    IO.puts("`devito URL SHORT_CODE`")
    IO.puts("`devito info`")
    IO.puts("`devito info SHORT_CODE`")
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

  defp show_list_table(json_list) do
    case Jason.decode(json_list) do
      {:ok, %{"links" => decoded}} ->
        print_header()
        Enum.each(decoded, &print_row/1)

      _ ->
        IO.puts("Could not print the link info")
    end
  end

  defp show_link(json) do
    case Jason.decode(json) do
      {:ok, decoded} ->
        print_header()
        print_row(decoded)

      _ ->
        IO.puts("Could not print the link info")
    end
  end

  defp print_header do
    IO.puts(
      String.pad_trailing("Short Code", 20) <>
        String.pad_trailing("Clicks", 7) <>
        String.pad_trailing("URL", 53)
    )

    IO.puts(
      String.pad_trailing("", 20, "_") <>
        String.pad_trailing("", 7, "_") <>
        String.pad_trailing("", 53, "_")
    )
  end

  defp print_row(%{
         "count" => count,
         "created_at" => _created_at,
         "short_code" => short_code,
         "url" => url
       }) do
    IO.puts(
      String.pad_trailing(short_code, 20) <>
        String.pad_trailing("#{count}", 7) <>
        String.pad_trailing(url, 53)
    )
  end

  defp print_row(bad_data), do: IO.inspect(bad_data)

  defp hash_token(nil), do: nil

  defp hash_token(token) do
    :sha256
    |> :crypto.hash(token)
    |> Base.encode64()
  end
end
