defmodule Jaang.Repo.Migrations.AddTotalItemsToInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :total_items, :integer
    end
  end
end
