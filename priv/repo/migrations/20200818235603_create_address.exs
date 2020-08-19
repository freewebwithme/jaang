defmodule Jaang.Repo.Migrations.CreateAddress do
  use Ecto.Migration

  def change do
    create table("addresses") do
      add :address_line_1, :string
      add :address_line_2, :string
      add :business_name, :string
      add :zipcode, :string
      add :city, :string
      add :state, :string
      add :instructions, :text

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
  end
end
