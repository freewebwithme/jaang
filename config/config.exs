# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :jaang,
  ecto_repos: [Jaang.Repo],
  start_apps_before_migration: [:logger]

# Configures the endpoint
config :jaang, JaangWeb.Endpoint,
  url: [host: "https://www.jaangcart.com"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: JaangWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Jaang.PubSub,
  live_view: [signing_salt: "KJsHXRjB"]

config :jaang, Jaang.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: System.get_env("MAILGUN_API_KEY"),
  domain: System.get_env("MAILGUN_DOMAIN_NAME"),
  base_uri: "https://api.mailgun.net/v3",
  hackney_opts: [
    recv_timeout: :timer.minutes(1)
  ]

config :jaang,
  google_client_id: System.get_env("GOOGLE_CLIENT_ID")

config :money,
  default_currency: :USD

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  region: {:system, "AWS_REGION"}

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]},
    identity: {Ueberauth.Strategy.Identity, [callback_methods: ["POST"]]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

config :recaptcha,
  public_key: {:system, "RECAPTCHA_PUBLIC_KEY"},
  secret: {:system, "RECAPTCHA_PRIVATE_KEY"},
  json_library: Jason

config :google_maps, api_key: System.get_env("GOOGLE_MAP_API")

config :stripity_stripe, api_key: System.get_env("STRIPE_SECRET_KEY")

config :tzdata, :data_dir, "etc/elixir_tzdata_data"

config :ex_signal,
  app_id: System.get_env("ONE_SIGNAL_APP_ID"),
  api_key: System.get_env("ONE_SIGNAL_API_KEY")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
