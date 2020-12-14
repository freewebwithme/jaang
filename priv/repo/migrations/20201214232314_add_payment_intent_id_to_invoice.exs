defmodule Jaang.Repo.Migrations.AddPaymentIntentIdToInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :pm_intent_id, :string
    end
  end
end
