defmodule Jaang.Category.Categories do
  @moduledoc """
  Function module related to Category Schema
  """
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

  def get_category_with_products(id) do
    Repo.get(Category, id) |> Repo.preload(:products)
  end

  def get_all_categories() do
    Repo.all(Category)
  end
end
