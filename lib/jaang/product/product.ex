defmodule Jaang.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Repo

  import Ecto.Query, warn: false

  schema "products" do
    field :name, :string
    field :description, :string
    field :ingredients, :string
    field :directions, :string
    field :warnings, :string
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

    many_to_many :tags, Jaang.Product.Tag,
      join_through: Jaang.Product.ProductTags,
      on_replace: :delete

    many_to_many :recipe_tags, Jaang.Product.RecipeTag,
      join_through: Jaang.Product.ProductRecipeTags,
      on_replace: :delete

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
      :ingredients,
      :directions,
      :warnings,
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
      :sub_category_name,
      :store_id
    ])
    |> put_assoc(:tags, parse_tags(attrs))
    |> put_assoc(:recipe_tags, parse_recipe_tags(attrs))
  end

  defp parse_tags(attrs) do
    (Map.get(attrs, :tags) || "")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> insert_and_get_all()
  end

  # put_assoc is used when I have already an associated struct so
  # before use put_assoc, do create a database record
  defp insert_and_get_all([]), do: []

  defp insert_and_get_all(names) do
    timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    maps = Enum.map(names, &%{name: &1, inserted_at: timestamp, updated_at: timestamp})
    Repo.insert_all(Jaang.Product.Tag, maps, on_conflict: :nothing)
    Repo.all(from(t in Jaang.Product.Tag, where: t.name in ^names))
  end

  defp parse_recipe_tags(attrs) do
    (Map.get(attrs, :recipe_tags) || "")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> insert_and_get_all_recipe_tags()
  end

  # put_assoc is used when I have already an associated struct so
  # before use put_assoc, do create a database record
  defp insert_and_get_all_recipe_tags([]), do: []

  defp insert_and_get_all_recipe_tags(names) do
    timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    maps = Enum.map(names, &%{name: &1, inserted_at: timestamp, updated_at: timestamp})
    Repo.insert_all(Jaang.Product.RecipeTag, maps, on_conflict: :nothing)
    Repo.all(from(t in Jaang.Product.RecipeTag, where: t.name in ^names))
  end
end
