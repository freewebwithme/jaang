defmodule Jaang.Repo.Migrations.ChangeHashedPasswordField do
  use Ecto.Migration

  def change do
    alter table("users") do
      remove :hashed_password, :string, null: false
      add :hashed_password, :string, null: true
    end
  end
end
