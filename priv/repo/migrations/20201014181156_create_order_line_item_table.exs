defmodule Jaang.Repo.Migrations.CreateOrderLineItemTable do
  use Ecto.Migration

  def change do
    create table("orders") do
      add :status, :string
      add :store_logo, :string
      add :total, :integer
      add :line_items, :map
      add :store_id, :integer
      add :store_name, :string
      add :invoice_id, :integer
      add :available_checkout, :boolean, default: false
      add :required_amount, :integer

      add :user_id, references("users")

      timestamps(type: :timestamptz)
    end
  end
end
