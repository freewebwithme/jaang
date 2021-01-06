defmodule Jaang.Repo.Migrations.AddDescriptionToCategory do
  use Ecto.Migration

  def change do
    alter table("categories") do
      add :description, :text
    end
  end
end
