defmodule Jaang.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, Comeonin.Ecto.Password

    has_one :profile, Jaang.Account.Profile
    has_many :addresses, Jaang.Account.Address

    timestamps()
  end

  @doc false
  def changeset(%Jaang.Account.User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_email?()
    |> cast_assoc(:profile, with: &Jaang.Account.Profile.changeset/2)
  end

  defp validate_email?(changeset) do
    case Map.has_key?(changeset.changes, :email) do
      false ->
        changeset

      _ ->
        case EmailChecker.Check.Format.valid?(changeset.changes.email) do
          true ->
            changeset

          _ ->
            add_error(changeset, :email, "Please enter vaild email format")
        end
    end
  end
end
