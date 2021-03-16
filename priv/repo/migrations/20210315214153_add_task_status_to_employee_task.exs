defmodule Jaang.Repo.Migrations.AddTaskStatusToEmployeeTask do
  use Ecto.Migration

  def change do
    alter table("employee_tasks") do
      add :task_status, :string
    end
  end
end
