defmodule Jaang.Repo.Migrations.AddGrandTotalAfterRefundToOrder do
  use Ecto.Migration

  def change do
    alter table("orders") do
      add :grand_total_after_refund, :integer
    end
  end
end
