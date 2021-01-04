defmodule Jaang.Repo.Migrations.RemovePriceFieldsFromProducts do
  use Ecto.Migration

  def change do
    alter table("products") do
      remove :regular_price, :integer
      remove :sale_price, :integer
    end
  end
end
