defmodule Jaang.Repo.Migrations.ChangeTotalItmesToTotalItemsInOrder do
  use Ecto.Migration

  def change do
    alter table("orders") do
      remove :total_itmes
      add :total_items, :integer
    end
  end
end
