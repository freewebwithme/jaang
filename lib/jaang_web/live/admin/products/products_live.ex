defmodule JaangWeb.Admin.Products.ProductsLive do
  use JaangWeb, :dashboard_live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
