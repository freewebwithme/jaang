defmodule Jaang.Repo.Migrations.CreateRefundRequestTable do
  use Ecto.Migration

  def change do
    create table("refund_requests") do
      add :status, :string
      add :total_refund, :integer
      add :refund_items, :map
      add :user_id, :id
      add :order_id, :id

      timestamps(type: :timestamptz)
    end
  end
end
