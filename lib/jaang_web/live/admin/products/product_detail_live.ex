defmodule JaangWeb.Admin.Products.ProductDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Product.Products
  alias JaangWeb.Admin.Products.ProductEditDetailLive
  @moduledoc false


  def mount(%{"store_id" => store_id, "product_id" => product_id}, _session, socket) do
    # get product
    product = Products.get_product(store_id, product_id)

    {:ok,
     assign(socket,
       current_page: "Product detail",
       product: product,
       store_id: store_id,
       product_id: product_id
     )}
  end

  def handle_event("edit", _, socket) do
    socket =
      push_redirect(
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
end
