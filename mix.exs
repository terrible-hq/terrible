defmodule Terrible.MixProject do
  use Mix.Project

  def project do
    [
      app: :terrible,
      version: "0.0.0",
      elixir: "1.14.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Terrible.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, "1.6.7", only: [:dev, :test], runtime: false},
      {:ecto_sql, "3.9.2"},
      {:esbuild, "0.6.1", runtime: Mix.env() == :dev},
      {:finch, "0.14.0"},
      {:floki, "0.34.1", only: :test},
      {:gettext, "0.22.0"},
      {:heroicons, "0.5.2"},
      {:jason, "1.4.0"},
      {:phoenix, "1.7.0-rc.2", override: true},
      {:phoenix_ecto, "4.4.0"},
      {:phoenix_html, "3.3.0"},
      {:phoenix_live_dashboard, "0.7.2"},
      {:phoenix_live_reload, "1.4.1", only: :dev},
      {:phoenix_live_view, "0.18.13"},
      {:plug_cowboy, "2.6.0"},
      {:postgrex, "0.16.5"},
      {:swoosh, "1.9.1"},
      {:tailwind, "0.1.10", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "0.6.1"},
      {:telemetry_poller, "1.0.0"},
      {:excoveralls, "0.15.3", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      lint: ["format", "credo"],
      "lint.ci": ["format --check-formatted", "credo"]
    ]
  end
end
