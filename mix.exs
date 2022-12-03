defmodule Jaang.MixProject do
  use Mix.Project

  def project do
    [
      app: :jaang,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Jaang.Application, []},
      extra_applications: [:timex, :tzdata, :logger, :runtime_tools, :os_mon]
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
      {:phoenix, "~> 1.7.0-rc.0"},
      {:phoenix_live_view, "~> 0.18"},
      {:floki, ">= 0.0.0", only: :test},
      {:phoenix_ecto, "~> 4.4.0"},
      {:ecto_sql, "~> 3.7.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0", override: true},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.7"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:absinthe, "~> 1.5"},
      {:absinthe_plug, "~> 1.5"},
      {:absinthe_phoenix, "~> 2.0"},
      {:money, "~> 1.7"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9", override: true},
      {:sweet_xml, "~> 0.6"},
      {:dataloader, "~> 1.0.0"},
      {:ueberauth, "~>0.10"},
      {:ueberauth_google, "~> 0.10"},
      {:ueberauth_identity, "~> 0.4"},
      {:bcrypt_elixir, "~> 2.0"},
      {:bamboo, "~> 2.0"},
      {:bamboo_phoenix, "~> 1.0"},
      {:recaptcha, "~> 3.0"},
      {:joken, "~> 2.2"},
      {:joken_jwks, "~> 1.4"},
      {:stripity_stripe, "~> 2.0"},
      {:google_maps, "~> 0.11.0"},
      {:uuid, "~> 1.1"},
      {:timex, "~> 3.6"},
      {:ex_signal, "~> 0.3.0"},
      {:date_time_parser, "~> 1.1.1"},
      {:xlsxir, "~> 1.6.4"},
      {:esbuild, "~> 0.4.0"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:phoenix_view, "~> 2.0"}
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
      # setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
