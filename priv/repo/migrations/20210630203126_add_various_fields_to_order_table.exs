defmodule Jaang.Repo.Migrations.AddVariousFieldsToOrderTable do
  use Ecto.Migration

  def change do
    alter table("orders") do
      add :delivery_time, :string
      add :delivery_date, :date
      add :delivery_order, :integer
      add :delivery_fee, :string
      add :delivery_tip, :integer
      add :sales_tax, :integer
      add :item_adjustment, :integer
      add :total_itmes, :integer
      add :number_of_bags, :integer, default: 0
      add :instruction, :string

      add :recipient, :string
      add :address_line_one, :string
      add :address_line_two, :string
      add :business_name, :string
      add :zipcode, :string
      add :city, :string
      add :state, :string

      add :phone_number, :string

      add :delivery_method, :string

      add :receipt_photos, :map
    end
  end
end
