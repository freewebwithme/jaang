defmodule Jaang.Repo.Migrations.CreateMaintenance do
  use Ecto.Migration

  def change do
    create table("maintenances") do
      add :message, :text
      add :in_maintenance_mode, :boolean, default: false
      add :start_datetime, :timestamptz
      add :end_datetime, :timestamptz

      timestamps(type: :timestamptz)
    end
  end
end
