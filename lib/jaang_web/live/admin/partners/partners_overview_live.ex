defmodule JaangWeb.Admin.Partners.PartnersOverviewLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Store.Stores
  alias Jaang.Store

  @moduledoc false

  def mount(_params, _session, socket) do
    store_infos = create_store_infos_from_store()

    socket =
      assign(socket,
        store_infos: store_infos,
        current_page: "Partners Overview",
        temporary_assigns: []
      )

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def handle_info({:new_partner_added, _store}, socket) do
    store_infos = create_store_infos_from_store()

    {:noreply,
     socket
     |> update(:store_infos, fn _value -> store_infos end)}
  end

  defp apply_action(socket, :add, _params) do
    socket
    |> assign(:page_title, "Add a partner")
    |> assign(:store, %Store{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Partners")
    |> assign(:store, nil)
  end

  defp create_store_infos_from_store() do
    # Get published products and unpublished products
    stores = Stores.get_store_with_products()

    Enum.reduce(stores, [], fn store, acc ->
      published_products = Enum.filter(store.products, &(&1.published == true))
      unpublished_products = Enum.filter(store.products, &(&1.published == false))
      num_orders = Enum.count(Stores.get_all_orders_for_store(store.id))

      store_info = %{
        store_id: store.id,
        store_name: store.name,
        store_logo: store.store_logo,
        num_orders: num_orders,
        published_products: Enum.count(published_products),
        unpublished_products: Enum.count(unpublished_products)
      }

      [store_info | acc]
    end)
  end
end
