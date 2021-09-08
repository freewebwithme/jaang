defmodule Jaang.Repo.Migrations.AddTotalAcceptedRefund do
  use Ecto.Migration

  def change do
    alter table("refund_requests") do
      remove :total_refund
      add :total_requested_refund, :integer
      add :total_accepted_refund, :integer
    end
  end
end
