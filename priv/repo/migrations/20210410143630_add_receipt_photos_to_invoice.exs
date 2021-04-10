defmodule Jaang.Repo.Migrations.AddReceiptPhotosToInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :receipt_photos, :map
    end
  end
end
