defmodule Jaang.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Need this for Google sign in that validate and verify id_token
      Jaang.Account.GoogleStrategy,
      # Start the Ecto repository
      Jaang.Repo,
      # Start the Telemetry supervisor
      JaangWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, [name: Jaang.PubSub, adapter: Phoenix.PubSub.PG2]},
      # Start the Endpoint (http/https)
      JaangWeb.Endpoint,
      {Absinthe.Subscription, JaangWeb.Endpoint}
      # Start a worker by calling: Jaang.Worker.start_link(arg)
      # {Jaang.Worker, arg}

      # Application.ensure_all_started(:timex)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jaang.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    JaangWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
