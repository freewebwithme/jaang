defmodule Jaang.Repo.Migrations.AddGrandTotalToOrder do
  use Ecto.Migration

  def change do
    alter table("orders") do
      add :grand_total, :integer
    end
  end
end
