# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :jaang,
  ecto_repos: [Jaang.Repo]

# Configures the endpoint
config :jaang, JaangWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "a1yHuHl7ERsUQ7vvodoxAWpwnS74z3jr2zMQcaS7QpTD6FNiQzSfFD98TjskDnAz",
  render_errors: [view: JaangWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Jaang.PubSub,
  live_view: [signing_salt: "KJsHXRjB"]

config :money,
  default_currency: :USD

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  region: {:system, "AWS_REGION"}

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, []},
    identity: {Ueberauth.Strategy.Identity, [callback_methods: ["POST"]]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
