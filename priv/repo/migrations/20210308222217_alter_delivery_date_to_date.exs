defmodule Jaang.Repo.Migrations.AlterDeliveryDateToDate do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      remove :delivery_date
      add :delivery_date, :date
    end
  end
end
