defmodule Jaang.Repo.Migrations.CreateEmployeeTable do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext", "DROP EXTENSION citext")

    create table("employees") do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      add :stripe_id, :string

      timestamps(type: :timestamptz)
    end

    create unique_index(:employees, [:email])
  end
end
