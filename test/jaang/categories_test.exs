defmodule Jaang.CategoriesTest do
  use Jaang.DataCase, async: true

  alias Jaang.StoreManager

  setup do
    {:ok, category} =
      StoreManager.create_category(%{
        name: "Category1"
      })

    {:ok, sub_category} = StoreManager.create_subcategory(category, %{name: "Subcategory1"})

    {:ok, product} =
      StoreManager.create_product(%{
        name: "Product1",
        category_id: category.id,
        category_name: category.name,
        sub_category_id: sub_category.id,
        sub_category_name: sub_category.name
      })

    {:ok, %{category: category, sub_category: sub_category, product: product}}
  end

  test "create category correctly?", context do
    assert context[:category].name == "Category1"
  end

  test "get category correctly?", context do
    category_id = context[:category].id
    category = StoreManager.get_category(category_id)
    assert category.id == category_id
  end

  test "get products by subcategory", context do
    sub_category_id = context[:sub_category].id
    products = StoreManager.get_products_by_sub_category(sub_category_id)

    assert products.name == "Product1"
  end
end
