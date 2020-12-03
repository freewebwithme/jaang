defmodule Jaang.CategoriesTest do
  use Jaang.DataCase, async: true

  alias Jaang.{StoreManager, ProductManager}

  setup do
    {:ok, store} =
      StoreManager.create_store(%{
        name: "Test market",
        address: "2740 W. Olympic Blvd LA CA 90006"
      })

    {:ok, category} =
      StoreManager.create_category(%{
        name: "Category1"
      })

    {:ok, sub_category} = StoreManager.create_subcategory(category, %{name: "Subcategory1"})

    {:ok, product} =
      ProductManager.create_product(%{
        name: "Product1",
        store_id: store.id,
        category_id: category.id,
        category_name: category.name,
        sub_category_id: sub_category.id,
        sub_category_name: sub_category.name
      })

    {:ok, %{category: category, sub_category: sub_category, product: product, store: store}}
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
    store_id = context[:store].id
    category_id = context[:category].id
    products = StoreManager.get_products_by_sub_category(category_id, store_id, 3)

    assert Enum.count(products) == 1
  end
end
