defmodule Jaang.Category.Categories do
  @moduledoc """
  Function module related to Category Schema
  """
  alias Jaang.Product
  alias Jaang.Category
  alias Jaang.Category.SubCategory
  alias Jaang.Repo
  import Ecto.Query

  def create_category(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def create_subcategory(category, attrs) do
    attrs = Map.put(attrs, :category_id, category.id)

    %SubCategory{}
    |> SubCategory.changeset(attrs)
    |> Repo.insert()
  end

  def get_category(id) do
    Repo.get(Category, id)
  end

  # TODO: Add limit to products(Pagination)
  def get_products_by_category(category_id, store_id) do
    cat_query = from c in Category, where: c.id == ^category_id

    prod_query =
      from cq in cat_query,
        join: p in Product,
        on: cq.id == p.category_id,
        where: p.store_id == ^store_id,
        select: cq

    Repo.all(prod_query)
  end

  def get_all_categories() do
    Repo.all(Category)
  end

  def get_products_by_sub_category(category_id, store_id) do
    query =
      from sc in SubCategory,
        where: sc.category_id == ^category_id,
        join: p in Product,
        on: sc.id == p.sub_category_id,
        where: p.store_id == ^store_id,
        select: p

    Repo.all(query)
    |> Enum.group_by(& &1.sub_category_name)
    |> Enum.map(fn {name, products} -> %{name: name, products: products} end)
  end
end
