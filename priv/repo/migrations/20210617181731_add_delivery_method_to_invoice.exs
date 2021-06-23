defmodule Jaang.Repo.Migrations.AddDeliveryMethodToInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :delivery_method, :string
    end
  end
end
