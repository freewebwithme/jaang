defmodule JaangWeb.Admin.Products.ProductDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Product.Products

  def mount(%{"store_id" => store_id, "product_id" => product_id}, _session, socket) do
    # get product
    product = Products.get_product(store_id, product_id)
    {:ok, assign(socket, current_page: "Product detail", product: product)}
  end
end
