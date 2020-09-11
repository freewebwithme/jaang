defmodule Jaang.Repo.Migrations.ChangePasswordToNotNullable do
  use Ecto.Migration

  def change do
    alter table("users") do
      remove :hashed_password, :string, null: true
      add :hashed_password, :string, null: false
    end
  end
end
