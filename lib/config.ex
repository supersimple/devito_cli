defmodule DevitoCLI.Config do
  @moduledoc """
  Handle config read/write for application.
  """
  @config_file "#{System.user_home()}/.devito"

  def get(key) do
    if config_file_exists?() do
      read_configs()
      |> Keyword.get(key, "")
    else
      default_configs()
    end
  end

  def write([{:api_url, _apiurl}, {:auth_token, _authtoken}] = config_opts) do
    new_config =
      if config_file_exists?() do
        Keyword.merge(read_configs(), config_opts, fn _k, v1, v2 ->
          if is_nil(v2), do: v1, else: v2
        end)
      else
        Keyword.merge(default_configs(), config_opts, fn _k, v1, v2 ->
          if is_nil(v2), do: v1, else: v2
        end)
      end

    File.write(@config_file, inspect(new_config))
  end

  def write(_invalid_format), do: :error

  defp config_file_exists?, do: File.exists?(@config_file)

  defp read_configs do
    {config, _} = Code.eval_file(@config_file)
    config
  rescue
    _e -> default_configs()
  end

  defp default_configs, do: [{:api_url, ""}, {:auth_token, ""}]
end
