defmodule Jaang.Account.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Account.Validator

  @type t :: module

  @derive {Jason.Encoder, except: [:__meta__, :password, :hashed_password, :addresses, :invoices]}
  schema "users" do
    field :email, :string
    field :stripe_id, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :confirmed_at, :utc_datetime

    has_one :profile, Jaang.Account.Profile
    has_many :addresses, Jaang.Account.Address
    has_many :invoices, Jaang.Invoice

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Jaang.Account.User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :stripe_id])
  end

  def registration_changeset(%Jaang.Account.User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password, :stripe_id])
    |> Validator.validate_email()
    |> Validator.validate_password()
    |> cast_assoc(:profile, with: &Jaang.Account.Profile.changeset/2)
  end

  def google_changeset(%Jaang.Account.User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password, :stripe_id])
    |> Validator.validate_email()
    |> generate_password()
    |> cast_assoc(:profile)
  end

  # This function will generate random password for google sign in.
  # Because password field is not nullable, we need to generate a password.
  defp generate_password(changeset) do
    random_password = :base64.encode(:crypto.strong_rand_bytes(30))

    changeset
    |> put_change(:password, random_password)
    # hash password
    |> prepare_changes(&Validator.hash_password/1)
  end

  @doc """
  A user changeset for changing the email.

  It requires the e-mail to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> Validator.validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not chage")
    end
  end

  @doc """
  A user changeset for changing the password.
  """
  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> Validator.validate_password()
  end

  @doc """
  Confirms the account by setting `comfirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(user, confirmed_at: now)
  end
end
