defmodule Jaang.Repo.Migrations.ChangeTimestampsToUtcInOrderTable do
  use Ecto.Migration

  def change do
    alter table("orders") do
      remove :inserted_at, :naive_datetime
      remove :updated_at, :naive_datetime

      timestamps(type: :timestamptz)
    end
  end
end
