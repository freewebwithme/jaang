defmodule Jaang.Product.ProductImage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "product_images" do
    field :image_url, :string
    field :order, :integer

    belongs_to :product, Jaang.Product
    timestamps(type: :utc_datetime)
  end

  def changeset(%Jaang.Product.ProductImage{} = product_image, attrs) do
    product_image
    |> cast(attrs, [:image_url, :order, :product_id])
  end
end
