defmodule Jaang.Repo.Migrations.AddTaxAndSubtotalToRefundRequest do
  use Ecto.Migration

  def change do
    alter table("refund_requests") do
      add :subtotal, :integer
      add :sales_tax, :integer
    end
  end
end
