defmodule Jaang.Store do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stores" do
    field :name, :string
    field :description, :string
    field :price_info, :string
    field :available_hours, :string
    field :address, :string
    field :phone_number, :string

    has_many :products, Jaang.Product
    timestamps()
  end

  @doc false
  def changeset(%Jaang.Store{} = store, attrs) do
    store
    |> cast(attrs, [:name, :description, :price_info, :available_hours, :address, :phone_number])
  end
end
