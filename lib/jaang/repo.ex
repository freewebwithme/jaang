defmodule Jaang.Repo do
  use Ecto.Repo,
    otp_app: :jaang,
    adapter: Ecto.Adapters.Postgres
end
