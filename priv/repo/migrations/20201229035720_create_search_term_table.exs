defmodule Jaang.Repo.Migrations.CreateSearchTermTable do
  use Ecto.Migration

  def change do
    create table("search_terms") do
      add :term, :string
      add :counter, :integer

      add :store_id, references(:stores, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index("search_terms", [:term])
  end
end
