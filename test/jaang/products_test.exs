defmodule Jaang.ProductsTest do
  use Jaang.DataCase, async: true

  alias Jaang.StoreManager
  alias Jaang.Product

  test "create product correctly? " do
    {:ok, product} =
      StoreManager.create_product(%{
        name: "Product1",
        description: "Product1 description",
        regular_price: 300,
        sale_price: 200,
        vendor: "Nongshim",
        published: true,
        barcode: "123"
      })

    assert product.name == "Product1"
    assert product.description == "Product1 description"
    assert product.regular_price == %Money{amount: 300, currency: :USD}
    assert product.sale_price == %Money{amount: 200, currency: :USD}
    assert product.vendor == "Nongshim"
    assert product.published == true
    assert product.barcode == "123"
  end

  test "create unit correctly?" do
    {:ok, unit} = StoreManager.create_unit(%{name: "lb"})
    assert unit.name == "lb"
  end

  test "create product with association correctly?" do
    {:ok, store} = StoreManager.create_store(%{name: "Store1"})
    {:ok, category} = StoreManager.create_category(%{name: "Category1"})

    {:ok, sub_category} = StoreManager.create_subcategory(category, %{name: "SubCategory1"})

    {:ok, product} =
      StoreManager.create_product(%{
        name: "Product1",
        description: "Product1 description",
        regular_price: 300,
        sale_price: 200,
        vendor: "Nongshim",
        published: true,
        barcode: "123",
        store_id: store.id,
        category_id: category.id,
        sub_category_id: sub_category.id
      })

    {:ok, _product_image1} =
      StoreManager.create_product_image(product, %{
        image_url: "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/yogurt.png",
        default: true
      })

    {:ok, _product_image2} =
      StoreManager.create_product_image(product, %{
        image_url: "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/tofu.jpg",
        default: false
      })

    product = StoreManager.get_product(product.id)

    assert product.name == "Product1"
    assert product.description == "Product1 description"
    assert product.regular_price == %Money{amount: 300, currency: :USD}
    assert product.sale_price == %Money{amount: 200, currency: :USD}
    assert product.vendor == "Nongshim"
    assert product.published == true
    assert product.barcode == "123"
    # Check association
    assert product.store_id == store.id
    assert product.category_id == category.id
    assert product.sub_category_id == sub_category.id

    # Get product with preload product images
    query = from p in Product, where: p.id == ^product.id
    product = Repo.one(query) |> Repo.preload(:product_images)

    product_images = product.product_images
    assert is_list(product_images)
    assert Enum.count(product_images) == 2
  end
end
