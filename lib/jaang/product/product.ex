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
    field :barcode, :string
    field :unit_id, :id
    field :unit_name, :string
    field :store_name, :string
    field :category_name, :string
    field :sub_category_name, :string

    has_many :product_images, Jaang.Product.ProductImage
    belongs_to :store, Jaang.Store
    belongs_to :category, Jaang.Category
    belongs_to :sub_category, Jaang.Category.SubCategory

    timestamps()
  end

  @doc false
  def changeset(%Jaang.Product{} = product, attrs) do
    product
    |> cast(attrs, [
      :name,
      :description,
      :regular_price,
      :sale_price,
      :vendor,
      :published,
      :barcode,
      :store_id,
      :category_id,
      :sub_category_id,
      :unit_id,
      :unit_name,
      :store_name,
      :category_name,
      :sub_category_name
    ])
  end
end
