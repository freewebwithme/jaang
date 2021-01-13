defmodule Jaang.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    # execute("CREATE EXTENSION citext", "DROP EXTENSION citext")

    create table("users") do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      add :stripe_id, :string

      timestamps(type: :timestamptz)
    end

    create unique_index(:users, [:email])
  end
end
