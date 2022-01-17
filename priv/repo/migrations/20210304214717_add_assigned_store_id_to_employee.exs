defmodule Jaang.Repo.Migrations.AddAssignedStoreIdToEmployee do
  use Ecto.Migration

  def change do
    alter table("employees") do
      add :assigned_store_id, :id, default: nil
    end
  end
end
