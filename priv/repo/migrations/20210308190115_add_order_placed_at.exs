defmodule Jaang.Repo.Migrations.AddOrderPlacedAt do
  use Ecto.Migration

  def change do
    alter table("orders") do
      add :order_placed_at, :timestamptz
    end

    alter table("invoices") do
      add :invoice_placed_at, :timestamptz
    end
  end
end
