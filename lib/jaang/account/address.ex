defmodule Jaang.Account.Address do
  use Ecto.Schema
  import Ecto.Changeset

  schema "addresses" do
    field :address_line_1, :string
    field :address_line_2, :string
    field :business_name, :string
    field :zipcode, :string
    field :city, :string
    field :state, :string
    field :instructions, :string

    belongs_to :user, Jaang.Account.User
    timestamps()
  end

  @doc false
  def changeset(%Jaang.Account.Address{} = address, attrs) do
    required_fields = [
      :address_line_1,
      :address_line_2,
      :business_name,
      :zipcode,
      :city,
      :state,
      :instructions
    ]

    address
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
  end
end
