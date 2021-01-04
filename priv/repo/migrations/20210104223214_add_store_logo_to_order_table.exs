defmodule Jaang.Repo.Migrations.AddStoreLogoToOrderTable do
  use Ecto.Migration

  def change do
    alter table("orders") do
      add :store_logo, :string
    end
  end
end
