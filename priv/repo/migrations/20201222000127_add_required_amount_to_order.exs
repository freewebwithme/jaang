defmodule Jaang.Repo.Migrations.AddRequiredAmountToOrder do
  use Ecto.Migration

  def change do
    alter table("orders") do
      add :required_amount, :integer
    end
  end
end
