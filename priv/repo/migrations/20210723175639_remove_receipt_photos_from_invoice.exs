defmodule Jaang.Repo.Migrations.RemoveReceiptPhotosFromInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      remove :receipt_photos
    end
  end
end
