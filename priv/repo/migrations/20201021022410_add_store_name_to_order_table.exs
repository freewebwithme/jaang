defmodule Jaang.Repo.Migrations.AddStoreNameToOrderTable do
  use Ecto.Migration

  def change do
    alter table("orders") do
      add :store_name, :string
    end
  end
end
