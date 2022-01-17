defmodule Jaang.Repo.Migrations.RemoveSomeFieldsFromInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      remove :recipient
      remove :address_line_one
      remove :address_line_two
      remove :business_name
      remove :zipcode
      remove :city
      remove :state
      remove :instructions
      remove :subtotal
      remove :driver_tip
      remove :delivery_fee
      remove :service_fee
      remove :sales_tax
      remove :item_adjustment
      remove :total
      remove :delivery_time
      remove :delivery_date
      remove :delivery_order
      remove :phone_number
      remove :number_of_bags
      remove :delivery_method
    end
  end
end
