defmodule Jaang.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION citext", "DROP EXTENSION citext")

    create table("users") do
      add :email, :citext, null: false
      add :password, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
