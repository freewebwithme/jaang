defmodule Jaang.Repo.Migrations.CreateAssignedWorkTable do
  use Ecto.Migration

  def change do
    create table("assigned_works") do
      add :invoice_id, :id
      add :assigned_at, :timestamptz
      add :finished_at, :timestamptz

      timestamps(type: :timestamptz)
    end
  end
end
