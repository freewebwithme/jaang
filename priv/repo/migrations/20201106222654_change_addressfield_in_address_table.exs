defmodule Jaang.Repo.Migrations.ChangeAddressfieldInAddressTable do
  use Ecto.Migration

  def change do
    alter table("addresses") do
      remove :address_line_1, :string
      remove :address_line_2, :string

      add :address_line_one, :string
      add :address_line_two, :string
    end
  end
end
