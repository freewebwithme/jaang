defmodule Jaang.Repo.Migrations.CreateOrderLineItemTable do
  use Ecto.Migration

  def change do
    create table("orders") do
      add :status, :string
      add :total, :integer
      add :line_items, :map
      add :store_id, :integer
      add :user_id, references("users")

      timestamps()
    end
  end
end
