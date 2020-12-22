defmodule Jaang.Repo.Migrations.AddItemAdjustmentsToInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :item_adjustment, :integer
    end
  end
end
