defmodule Jaang.Repo.Migrations.AddAvailableCheckoutToOrderTable do
  use Ecto.Migration

  def change do
    alter table("orders") do
      add :available_checkout, :boolean, default: false
    end
  end
end
