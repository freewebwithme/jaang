defmodule JaangWeb.Admin.Products.ProductsLive do
  @moduledoc """
  Show list of Stores
  """
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Store.Stores
  alias JaangWeb.Admin.Products.ProductsListLive

  def mount(_params, _session, socket) do
    stores = Stores.list_stores()
    socket = assign(socket, current_page: "Products", stores: stores)
    {:ok, socket}
  end
end
