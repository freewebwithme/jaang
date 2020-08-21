defmodule Jaang.Account.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profiles" do
    field :first_name, :string
    field :last_name, :string
    field :phone, :string

    belongs_to :user, Jaang.Account.User
    timestamps()
  end

  @doc false
  def changeset(%Jaang.Account.Profile{} = profile, attrs) do
    profile
    |> cast(attrs, [:first_name, :last_name, :phone, :user_id])
  end
end