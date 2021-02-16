defmodule Jaang.Admin.Account.Employee.EmployeeProfile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employee_profiles" do
    field :first_name, :string
    field :last_name, :string
    field :phone, :string
    field :photo_url, :string

    belongs_to :employee, Jaang.Admin.Account.Employee.Employee
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = employee_profile, attrs) do
    employee_profile
    |> cast(attrs, [:first_name, :last_name, :phone, :photo_url, :employee_id])
    |> validate_required([:first_name, :last_name, :phone, :employee_id])
  end
end
