defmodule Jaang.Repo.Migrations.RenameTaskTypeFieldInEmployeeTask do
  use Ecto.Migration

  def change do
    alter table("employee_tasks") do
      remove :tast_type
      add :task_type, :string
    end
  end
end
