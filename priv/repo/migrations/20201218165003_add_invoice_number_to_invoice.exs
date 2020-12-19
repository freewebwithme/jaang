defmodule Jaang.Repo.Migrations.AddInvoiceNumberToInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :invoice_number, :string
    end
  end
end
