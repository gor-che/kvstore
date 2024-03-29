defmodule Dbase.MixProject do
  use Mix.Project

  def project do
    [
      app: :dbase,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
	extra_applications: [:logger],
	mod: {KVStore, []},
	env: [cowboy_port: 8080]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
    	{:cowboy, "~> 1.1.2"},
    	{:plug, "~> 1.3.4"}
    ]
  end
end
