defmodule Jaang.Repo.Migrations.AddEmployeesFieldToInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :shopper_id, :integer
      add :driver_id, :integer
    end
  end
end
