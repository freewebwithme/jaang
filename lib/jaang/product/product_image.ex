defmodule Jaang.Product.ProductImage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "product_images" do
    field :image_url, :string
    field :default, :boolean, default: false

    belongs_to :product, Jaang.Product
    timestamps()
  end

  def changeset(%Jaang.Product.ProductImage{} = product_image, attrs) do
    product_image
    |> cast(attrs, [:image_url, :default, :product_id])
  end
end
