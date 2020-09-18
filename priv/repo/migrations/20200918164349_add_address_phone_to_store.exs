defmodule Jaang.Repo.Migrations.AddAddressPhoneToStore do
  use Ecto.Migration

  def change do
    alter table("stores") do
      add :address, :string
      add :phone_number, :string
    end
  end
end
