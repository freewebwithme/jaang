defmodule Jaang.Admin.Account.AdminUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Admin.Account.AdminUser
  alias Jaang.Account.Validator

  schema "admin_users" do
    field :email, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :confirmed_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%AdminUser{} = admin_user, attrs \\ %{}) do
    admin_user
    |> cast(attrs, [:email, :password])
  end

  def registration_changeset(%AdminUser{} = admin_user, attrs \\ %{}) do
    admin_user
    |> cast(attrs, [:email, :password])
    |> Validator.validate_email()
    |> Validator.validate_password()
  end

  @doc """
  A admin_user changeset for changing the email.

  It requires the e-mail to change otherwise an error is added.
  """
  def email_changeset(admin_user, attrs) do
    admin_user
    |> cast(attrs, [:email])
    |> Validator.validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not chage")
    end
  end

  @doc """
  A admin_user changeset for changing the password.
  """
  def password_changeset(admin_user, attrs) do
    admin_user
    |> cast(attrs, [:password])
    |> Validator.validate_password()
  end

  @doc """
  Confirms the account by setting `comfirmed_at`.
  """
  def confirm_changeset(admin_user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(admin_user, confirmed_at: now)
  end
end
