defmodule Jaang.Repo.Migrations.ChangeStoreIdFieldToProfile do
  use Ecto.Migration

  def change do
    alter table("profiles") do
      remove :store_id, :string
      add :store_id, :id, default: nil
    end
  end
end
