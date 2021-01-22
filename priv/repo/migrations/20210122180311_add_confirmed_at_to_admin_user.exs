defmodule Jaang.Repo.Migrations.AddConfirmedAtToAdminUser do
  use Ecto.Migration

  def change do
    alter table("admin_users") do
      add :confirmed_at, :naive_datetime
    end
  end
end
