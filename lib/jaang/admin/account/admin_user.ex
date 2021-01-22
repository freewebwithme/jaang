defmodule Jaang.Admin.Account.AdminUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Admin.Account.AdminUser

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
    |> validate_email()
    |> validate_password()
  end

  def validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Jaang.Repo)
    |> unique_constraint(:email)
  end

  def validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 80)
    #    |> validate_confirmation(:password, message: "does not match password", required: true)
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> prepare_changes(&hash_password/1)
  end

  def hash_password(changeset) do
    password = get_change(changeset, :password)

    changeset
    |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
    |> delete_change(:password)
  end

  @doc """
  A admin_user changeset for changing the email.

  It requires the e-mail to change otherwise an error is added.
  """
  def email_changeset(admin_user, attrs) do
    admin_user
    |> cast(attrs, [:email])
    |> validate_email()
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
    |> validate_password()
  end

  @doc """
  Confirms the account by setting `comfirmed_at`.
  """
  def confirm_changeset(admin_user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(admin_user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a passowrd, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%AdminUser{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
