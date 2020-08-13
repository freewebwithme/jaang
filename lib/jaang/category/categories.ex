defmodule Jaang.Category.Categories do
  @moduledoc """
  Function module related to Category Schema
  """
  alias Jaang.Product
  alias Jaang.Category
  alias Jaang.Category.SubCategory
  alias Jaang.Repo

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
  def get_products_by_category(id) do
    Repo.get(Category, id)
  end

  def get_all_categories() do
    Repo.all(Category)
  end

  def get_products_by_sub_category(id) do
    Repo.get_by(Product, sub_category_id: id)
  end
end
