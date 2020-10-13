defmodule Jaang.Product.ProductRecipeTags do
  use Ecto.Schema

  schema "product_recipe_tags" do
    belongs_to :product, Jaang.Product
    belongs_to :recipe_tag, Jaang.Product.Tag

    timestamps()
  end
end
