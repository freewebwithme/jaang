defmodule Jaang.Repo.Migrations.AddActiveFieldToEmployeeTable do
  use Ecto.Migration

  def change do
    alter table("employees") do
      add :active, :boolean, default: false
    end
  end
end
