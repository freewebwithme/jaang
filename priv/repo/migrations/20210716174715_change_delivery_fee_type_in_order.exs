defmodule Jaang.Repo.Migrations.ChangeDeliveryFeeTypeInOrder do
  use Ecto.Migration

  def change do
    alter table("orders") do
      remove :delivery_fee
      add :delivery_fee, :integer
    end
  end
end
