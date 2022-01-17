defmodule Jaang.Repo.Migrations.CreateEmployeeTask do
  use Ecto.Migration

  def change do
    create table("employee_tasks") do
      add :tast_type, :string
      add :start_datetime, :timestamptz
      add :end_datetime, :timestamptz
      add :duration, :integer
      add :invoice_id, :id
      add :order_id, :id

      add :line_items, :map
      add :employee_id, references(:employees)

      timestamps(type: :timestamptz)
    end
  end
end
