defmodule Jaang.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :description, :string
    field :regular_price, Money.Ecto.Amount.Type
    field :sale_price, Money.Ecto.Amount.Type
    field :vendor, :string
    field :published, :boolean

    has_one :unit, Jaang.Product.Unit
    belongs_to :store, Jaang.Store
    belongs_to :category, Jaang.Category
  end

  @doc false
  def changeset(%Jaang.Product{} = product, attrs) do
    product
    |> cast(attrs, [:name, :description, :regular_price, :sale_price, :vendor, :published])
  end
end
