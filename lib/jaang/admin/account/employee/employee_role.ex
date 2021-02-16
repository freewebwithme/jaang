defmodule Jaang.Admin.Account.Employee.EmployeeRole do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employee_roles" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = employee_role, attrs) do
    employee_role
    |> cast(attrs, [:name])
    |> unique_constraint(:name)
  end
end
