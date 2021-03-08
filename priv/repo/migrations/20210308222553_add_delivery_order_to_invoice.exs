defmodule Jaang.Repo.Migrations.AddDeliveryOrderToInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :delivery_order, :integer
    end
  end
end
