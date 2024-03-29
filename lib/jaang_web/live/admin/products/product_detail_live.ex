defmodule JaangWeb.Admin.Products.ProductDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Product.Products
  alias JaangWeb.Admin.Products.{ProductEditDetailLive, ProductsListLive}
  @moduledoc false

  def mount(
        %{"store_id" => store_id, "product_id" => product_id},
        _session,
        socket
      ) do
    # get product
    product = Products.get_product(store_id, product_id)

    {:ok,
     assign(socket,
       current_page: "Product detail",
       product: product,
       store_id: store_id,
       product_id: product_id,
       store_name: product.store_name
     )}
  end

  def handle_event("edit", _, socket) do
    socket =
      push_navigate(
        socket,
        to:
          Routes.live_path(
            socket,
            ProductEditDetailLive,
            socket.assigns.store_id,
            socket.assigns.product_id
          )
      )

    {:noreply, socket}
  end

  def handle_event("goback", _, socket) do
    socket =
      push_navigate(
        socket,
        to:
          Routes.live_path(
            socket,
            ProductsListLive,
            socket.assigns.store_name,
            socket.assigns.store_id
          )
      )

    {:noreply, socket}
  end
end
