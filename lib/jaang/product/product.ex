defmodule Jaang.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Repo
  alias Jaang.Product.{Tag, RecipeTag}

  import Ecto.Query, warn: false

  schema "products" do
    field :name, :string
    field :description, :string
    field :ingredients, :string
    field :directions, :string
    field :warnings, :string
    field :vendor, :string
    field :published, :boolean
    field :barcode, :string
    field :unit_name, :string
    field :store_name, :string
    field :category_name, :string
    field :sub_category_name, :string
    field :weight_based, :boolean, default: false

    has_many :market_prices, Jaang.Product.MarketPrice
    has_many :product_prices, Jaang.Product.ProductPrice
    has_many :product_images, Jaang.Product.ProductImage

    many_to_many :tags, Jaang.Product.Tag,
      join_through: Jaang.Product.ProductTags,
      on_replace: :delete

    many_to_many :recipe_tags, Jaang.Product.RecipeTag,
      join_through: Jaang.Product.ProductRecipeTags,
      on_replace: :delete

    belongs_to :store, Jaang.Store
    belongs_to :category, Jaang.Category
    belongs_to :sub_category, Jaang.Category.SubCategory

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Jaang.Product{} = product, attrs) do
    product
    |> cast(attrs, [
      :name,
      :description,
      :ingredients,
      :directions,
      :warnings,
      :vendor,
      :published,
      :weight_based,
      :barcode,
      :store_id,
      :category_id,
      :sub_category_id,
      :unit_name,
      :store_name,
      :category_name,
      :sub_category_name,
      :sub_category_id,
      :store_id
    ])
    |> put_assoc(:tags, Tag.parse_tags(attrs))
    |> put_assoc(:recipe_tags, RecipeTag.parse_recipe_tags(attrs))
  end

  @doc """
  Accept list of %Tag{} or %RecipeTag{} and
  return "snacks, tea, candy" format
  """
  def build_recipe_tag_name_to_string(tags) do
    Enum.reduce(tags, "", fn tag, acc ->
      if acc == "" do
        acc <> tag.name
      else
        acc <> ", " <> tag.name
      end
    end)
  end
end
