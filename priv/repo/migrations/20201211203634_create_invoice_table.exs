defmodule Jaang.Repo.Migrations.CreateInvoiceTable do
  use Ecto.Migration

  def change do
    create table("invoices") do
      add :subtotal, :string
      add :driver_tip, :string
      add :delivery_fee, :string
      add :service_fee, :string
      add :sales_tax, :string
      add :total, :string
      add :payment_method, :string
      add :address_id, :integer
      add :user_id, :integer

      timestamps()
    end
  end
end
