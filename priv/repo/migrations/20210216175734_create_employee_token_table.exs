defmodule Jaang.Repo.Migrations.CreateEmployeeTokenTable do
  use Ecto.Migration

  def change do
    create table("employee_tokens") do
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      add :employee_id, references(:employees, on_delete: :delete_all), null: false

      timestamps(updated_at: false)
    end

    create index(:employee_tokens, [:employee_id])
    create unique_index(:employee_tokens, [:context, :token])
  end
end
