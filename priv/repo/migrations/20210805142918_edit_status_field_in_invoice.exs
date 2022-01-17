defmodule Jaang.Repo.Migrations.EditStatusFieldInInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      remove :status
      add :status, :string
    end
  end
end
