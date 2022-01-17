defmodule Jaang.Repo.Migrations.AddDeliveryDateToInvoiceTable do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :delivery_date, :timestamptz
    end
  end
end
