defmodule Jaang.Repo.Migrations.AddArchivedToMaintenance do
  use Ecto.Migration

  def change do
    alter table("maintenances") do
      add :archived, :boolean, default: false
    end
  end
end
