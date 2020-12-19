defmodule Jaang.Repo.Migrations.AddRecipientToAddresses do
  use Ecto.Migration

  def change do
    alter table("addresses") do
      add :recipient, :string
    end
  end
end
