defmodule Jaang.Admin.Account.Employee.EmployeeRole do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employee_roles" do
    field :name, :string

    many_to_many :employees, Jaang.Admin.Account.Employee.Employee,
      join_through: Jaang.Admin.Account.Employee.EmployeeEmployeeRole

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = employee_role, attrs) do
    employee_role
    |> cast(attrs, [:name])
    |> validate_required(:name)
    |> validate_length(:name, min: 3, max: 20)
    |> unique_constraint(:name)
  end
end
