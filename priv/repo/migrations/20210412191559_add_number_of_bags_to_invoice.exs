defmodule Jaang.Repo.Migrations.AddNumberOfBagsToInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      remove :shopper_id
      remove :driver_id
      add :number_of_bags, :integer, default: 0
    end
  end
end
