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
  end
end
