defmodule Jaang.Account.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profiles" do
    field :first_name, :string
    field :last_name, :string
    field :phone, :string
    field :photo_url, :string
    field :store_id, :id, default: nil

    belongs_to :user, Jaang.Account.User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Jaang.Account.Profile{} = profile, attrs) do
    profile
    |> cast(attrs, [:first_name, :last_name, :phone, :user_id, :store_id, :photo_url])
  end
end
