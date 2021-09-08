defmodule Jaang.Repo.Migrations.AddDenyReasonToRefundRequest do
  use Ecto.Migration

  def change do
    alter table("refund_requests") do
      add :deny_reason, :text
    end
  end
end
