defmodule JaangWeb.Admin.Products.ProductEditDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Product
  alias Jaang.Admin.Product.Products

  def mount(%{"store_id" => store_id, "product_id" => product_id}, _session, socket) do
    product = Products.get_product(store_id, product_id)
    changeset = Product.changeset(product, %{})

    socket =
      assign(socket, current_page: "Edit Product detail", product: product, changeset: changeset)

    {:ok, socket}
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
