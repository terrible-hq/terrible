defmodule Terrible.MixProject do
  use Mix.Project

  def project do
    [
      app: :terrible,
      version: "0.1.0",
      elixir: "1.15.2",
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
      {:ash, "2.11.8"},
      {:ash_authentication, "3.11.6"},
      {:ash_authentication_phoenix, "1.7.2"},
      {:ash_phoenix, "1.2.15"},
      {:ash_postgres, "1.3.32"},
      {:credo, "1.7.0", only: [:dev, :test], runtime: false},
      {:ecto_sql, "3.10.1"},
      {:esbuild, "0.7.1", runtime: Mix.env() == :dev},
      {:excoveralls, "0.16.1", only: :test},
      {:finch, "0.16.0"},
      {:floki, "0.34.3", only: :test},
      {:gettext, "0.22.3"},
      {:heroicons, "0.5.3"},
      {:jason, "1.4.1"},
      {:phoenix, "1.7.7"},
      {:phoenix_ecto, "4.4.2"},
      {:phoenix_html, "3.3.1"},
      {:phoenix_live_dashboard, "0.8.0"},
      {:phoenix_live_reload, "1.4.1", only: :dev},
      {:phoenix_live_view, "0.19.4"},
      {:plug_cowboy, "2.6.1"},
      {:postgrex, "0.17.2"},
      {:swoosh, "1.11.4"},
      {:tailwind, "0.2.1", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "0.6.1"},
      {:telemetry_poller, "1.0.0"}
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
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ash_postgres.create", "ash_postgres.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ash_postgres.drop", "ecto.setup"],
      test: [
        "ash_postgres.drop",
        "ash_postgres.create --quiet",
        "ash_postgres.migrate --quiet",
        "test"
      ],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      lint: ["format", "credo"],
      "lint.ci": ["format --check-formatted", "credo"]
    ]
  end
end
