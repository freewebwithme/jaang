defmodule Jaang.Repo.Migrations.AddInvoiceIdToOrder do
  use Ecto.Migration

  def change do
    alter table("orders") do
      add :invoice_id, :integer
    end
  end
end
