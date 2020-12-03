defmodule Jaang.Account.Address do
  use Ecto.Schema
  import Ecto.Changeset

  schema "addresses" do
    field :address_line_one, :string
    field :address_line_two, :string
    field :business_name, :string
    field :zipcode, :string
    field :city, :string
    field :state, :string
    field :instructions, :string
    field :default, :boolean, default: false

    belongs_to :user, Jaang.Account.User
    has_one :distance, Jaang.Distance
    timestamps()
  end

  @doc false
  def changeset(%Jaang.Account.Address{} = address, attrs) do
    required_fields = [
      :address_line_one,
      :zipcode,
      :city,
      :state,
      :user_id
    ]

    address
    |> cast(
      attrs,
      [:default, :business_name, :instructions, :address_line_two] ++ required_fields
    )
    |> validate_required(required_fields)
  end
end
