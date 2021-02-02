defmodule JaangWeb.Admin.Products.ProductsListLive do
  use JaangWeb, :dashboard_live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
