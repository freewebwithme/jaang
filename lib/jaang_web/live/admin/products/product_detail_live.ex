defmodule JaangWeb.Admin.Products.ProductDetailLive do
  use JaangWeb, :dashboard_live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, current_page: "Product detail")}
  end
end
