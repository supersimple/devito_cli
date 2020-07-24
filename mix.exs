defmodule DevitoCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :devito_cli,
      version: "0.1.1",
      elixir: "~> 1.10",
      escript: escript_config(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp escript_config do
    [main_module: DevitoCLI, name: "devito", comment: "Makes URLs short"]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hackney, "~> 1.16"},
      {:jason, "~> 1.2"}
    ]
  end
end
