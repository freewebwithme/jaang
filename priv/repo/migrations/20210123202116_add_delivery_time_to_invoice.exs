defmodule Jaang.Repo.Migrations.AddDeliveryTimeToInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :delivery_time, :string
    end
  end
end
