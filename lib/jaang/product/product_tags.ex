defmodule Jaang.Product.ProductTags do
  use Ecto.Schema

  schema "product_tags" do
    belongs_to :product, Jaang.Product
    belongs_to :tag, Jaang.Product.Tag
    timestamps(type: :utc_datetime)
  end
end
