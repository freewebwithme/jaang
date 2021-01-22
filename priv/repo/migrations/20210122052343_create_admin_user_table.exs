defmodule Jaang.Repo.Migrations.CreateAdminUserTable do
  use Ecto.Migration

  def change do
    create table("admin_users") do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false

      timestamps(type: :timestamptz)
    end

    create unique_index(:admin_users, [:email])
  end
end
