defmodule Jaang.Repo.Migrations.CreateInvoiceTable do
  use Ecto.Migration

  def change do
    create table("invoices") do
      add :invoice_number, :string
      add :subtotal, :integer
      add :driver_tip, :integer
      add :delivery_fee, :integer
      add :service_fee, :integer
      add :sales_tax, :integer
      add :total_items, :integer
      add :total, :integer
      add :item_adjustment, :integer
      add :payment_method, :string
      add :status, :string
      add :pm_intent_id, :string
      add :phone_number, :string

      add :recipient, :string
      add :address_line_one, :string
      add :address_line_two, :string
      add :business_name, :string
      add :zipcode, :string
      add :city, :string
      add :state, :string
      add :instructions, :string

      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end
  end
end
