defmodule Jaang.Repo.Migrations.CreateInvoiceTable do
  use Ecto.Migration

  def change do
    create table("invoices") do
      add :subtotal, :integer
      add :driver_tip, :integer
      add :delivery_fee, :integer
      add :service_fee, :integer
      add :sales_tax, :integer
      add :total, :integer
      add :payment_method, :string
      add :status, :string
      add :address_id, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
  end
end
