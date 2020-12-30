defmodule Jaang.Repo.Migrations.AddStoreLogo do
  use Ecto.Migration

  def change do
    alter table("stores") do
      add :store_logo, :string
    end
  end
end
