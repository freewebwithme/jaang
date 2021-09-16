defmodule Jaang.Repo.Migrations.CreateCustomerMessage do
  use Ecto.Migration

  def change do
    create table("customer_messages") do
      add :status, :string
      add :message, :text
      add :user_id, :id
      add :order_id, :id

      timestamps(type: :timestamptz)
    end
  end
end
