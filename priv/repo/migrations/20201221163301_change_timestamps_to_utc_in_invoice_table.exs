defmodule Jaang.Repo.Migrations.ChangeTimestampsToUtcInInvoiceTable do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      remove :inserted_at, :naive_datetime
      remove :updated_at, :naive_datetime

      timestamps(type: :timestamptz)
    end
  end
end
