defmodule Jaang.Repo.Migrations.AddStoreIdToProfile do
  use Ecto.Migration

  def change do
    alter table("profiles") do
      add :store_id, :string, default: nil
    end
  end
end
