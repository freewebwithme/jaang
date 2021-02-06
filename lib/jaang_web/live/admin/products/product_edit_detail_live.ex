defmodule JaangWeb.Admin.Products.ProductEditDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Product
  alias Jaang.Admin.Product.Products
  alias Jaang.Category.Categories

  def mount(%{"store_id" => store_id, "product_id" => product_id}, _session, socket) do
    product = Products.get_product(store_id, product_id)
    changeset = Product.changeset(product, %{})
    categories = Categories.get_all_categories()
    sub_categories = Categories.list_sub_category(product.category_id)

    socket =
      assign(socket,
        current_page: "Edit Product detail",
        product: product,
        changeset: changeset,
        categories: categories,
        sub_categories: sub_categories
      )

    {:ok, socket}
  end

  def handle_event("form_changed", params, socket) do
    IO.puts("form changed")
    IO.inspect(params)

    %{
      "_target" => targets,
      "product" => %{
        "category" => %{"id" => _old_id, "name" => new_category_id},
        "sub_category" => %{"id" => _old_sub_id, "name" => _new_sub_category_id}
      }
    } = params

    # If there is "category" in _target map, update subcategory list
    socket =
      if Enum.member?(targets, "category") do
        # Category changed, so call sub categories
        sub_categories = Categories.list_sub_category(new_category_id)
        assign(socket, sub_categories: sub_categories)
      end

    {:noreply, socket}
  end

  def handle_event("product_update", params, socket) do
    IO.puts("Product updated")
    IO.inspect(params)
    {:noreply, socket}
  end

  def handle_event("change_image", _, socket) do
    {:noreply, socket}
  end

  def handle_event("delete_image", _, socket) do
    {:noreply, socket}
  end

  def handle_event("add_image", _, socket) do
    {:noreply, socket}
  end
end
