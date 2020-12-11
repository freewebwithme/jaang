defmodule Jaang.Repo.Migrations.AddStatusInvoiceTable do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :status, :string
    end
  end
end
