defmodule Jaang.Repo.Migrations.AddEmployeeIdToOrderTable do
  use Ecto.Migration

  def change do
    alter table("orders") do
      add :employee_id, references(:employees, on_delete: :nothing)
    end
  end
end
