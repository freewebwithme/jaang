defmodule Jaang.Repo.Migrations.AddWeightBasedToProductTable do
  use Ecto.Migration

  def change do
    alter table("products") do
      add :weight_based, :boolean, default: false
    end
  end
end
