defmodule Jaang.Repo.Migrations.AddMarketPriceTable do
  use Ecto.Migration

  def change do
    create table("market_prices") do
      add :start_date, :timestamptz
      add :end_date, :timestamptz
      add :discount_percentage, :string
      add :on_sale, :boolean, default: false
      add :original_price, :integer
      add :sale_price, :integer

      add :product_id, references(:products, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end
  end
end
