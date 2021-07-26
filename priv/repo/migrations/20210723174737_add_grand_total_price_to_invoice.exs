defmodule Jaang.Repo.Migrations.AddGrandTotalPriceToInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :grand_total_price, :integer
    end
  end
end
