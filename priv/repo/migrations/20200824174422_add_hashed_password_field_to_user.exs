defmodule Jaang.Repo.Migrations.AddHashedPasswordFieldToUser do
  use Ecto.Migration

  def change do
    alter table("users") do
      remove :password
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
    end
  end
end
