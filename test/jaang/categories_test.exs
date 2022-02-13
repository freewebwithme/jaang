defmodule Jaang.CategoriesTest do
  use Jaang.DataCase, async: true

  alias Jaang.{StoreManager, ProductManager}
  alias Jaang.Category.Categories

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

    product =
      ProductManager.create_product(%{
        name: "Product1",
        description: "Product1 description",
        vendor: "Bingrae",
        barcode: "1234",
        original_price: "7.99",
        store_id: store.id,
        weight_based: false,
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

  test "list_categories/0 correctly?", context do
    category = context[:category]
    categories = Categories.list_categories()

    assert Enum.count(categories) == 1

    [retrieved_cat] = Enum.take(categories, 1)

    assert category.name == retrieved_cat.name
  end

  test "list_sub_categories/0 correctly?", context do
    category = context[:category]
    sub_category = context[:sub_category]
    sub_categories = Categories.list_sub_categories(category.id)

    assert Enum.count(sub_categories) == 1

    [retrieved_sub_cat] = Enum.take(sub_categories, 1)

    assert sub_category.name == retrieved_sub_cat.name
    assert sub_category.category_id == category.id
  end

  test "get products by subcategory", context do
    store_id = context[:store].id
    category_id = context[:category].id
    products = StoreManager.get_products_by_sub_category(category_id, store_id, 3)

    assert Enum.count(products) == 1
  end

  test "get_products_by_category/3 correctly?", context do
    store = context[:store]
    category = context[:category]
    product = context[:product]

    products = StoreManager.get_products_by_category(category.id, store.id, 2)
    assert Enum.count(products) == 1

    [retrieved_product] = Enum.take(products, 1)

    assert product.name == retrieved_product.name
    assert product.store_id == retrieved_product.store_id
    assert product.category_id == retrieved_product.category_id
  end

  test "get_products_by_sub_category_name/4 correctly?", context do
    store = context[:store]
    sub_category = context[:sub_category]

    products = StoreManager.get_products_by_sub_category_name(sub_category.name, store.id, 3, 0)

    assert Enum.count(products) == 1

    [retrieved_product] = Enum.take(products, 1)

    assert sub_category.name == retrieved_product.sub_category_name
  end
end
