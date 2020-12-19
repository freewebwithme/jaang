defmodule Jaang.Repo.Migrations.AddAddressInfoToInvoices do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      remove :address_id, :integer

      add :recipient, :string
      add :address_line_one, :string
      add :address_line_two, :string
      add :business_name, :string
      add :zipcode, :string
      add :city, :string
      add :state, :string
      add :instructions, :string
    end
  end
end
