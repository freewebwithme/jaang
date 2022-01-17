defmodule Jaang.Admin.Account.Employee.Employee do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Account.Validator

  schema "employees" do
    field :email, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :stripe_id, :string
    field :confirmed_at, :utc_datetime
    field :active, :boolean, default: false

    has_one :employee_profile, Jaang.Admin.Account.Employee.EmployeeProfile, on_replace: :update
    has_many :employee_tasks, Jaang.Admin.EmployeeTask

    many_to_many :assigned_stores, Jaang.Store,
      join_through: Jaang.Admin.Account.Employee.EmployeeAssignedStore,
      on_replace: :delete

    many_to_many :roles, Jaang.Admin.Account.Employee.EmployeeRole,
      join_through: Jaang.Admin.Account.Employee.EmployeeEmployeeRole,
      on_replace: :delete

    many_to_many :orders, Jaang.Checkout.Order,
      join_through: Jaang.Admin.Account.Employee.EmployeeAssignedOrder

    many_to_many :invoices, Jaang.Invoice,
      join_through: Jaang.Admin.Account.Employee.EmployeeAssignedInvoice,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = employee, attrs) do
    employee
    |> cast(attrs, [:email, :stripe_id, :active])
    |> validate_required(:email)
    |> cast_assoc(:employee_profile)
  end

  @doc false
  def registration_changeset(%__MODULE__{} = employee, attrs) do
    employee
    |> cast(attrs, [:email, :password, :active, :stripe_id])
    |> Validator.validate_email()
    |> Validator.validate_password()
    |> cast_assoc(:employee_profile)
  end

  @doc """
  A employee changeset for changing the email.

  It requires the e-mail to change otherwise an error is added.
  """
  def email_changeset(employee, attrs) do
    employee
    |> cast(attrs, [:email])
    |> Validator.validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A employee changeset for changing the password.
  """
  def password_changeset(employee, attrs) do
    employee
    |> cast(attrs, [:password])
    |> Validator.validate_password()
  end

  @doc """
  Confirms the account by setting `comfirmed_at`.
  """
  def confirm_changeset(employee) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(employee, confirmed_at: now)
  end
end
