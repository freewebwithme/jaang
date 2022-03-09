defmodule JaangWeb.Admin.Partners.PartnersOverviewLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Store.Stores

  def mount(_params, _session, socket) do
    # Get published products and unpublished products
    stores = Stores.get_store_with_products()

    store_infos =
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
          unpublished_products: Enum.count(unpublished_products),
        }

        [store_info | acc]
      end)

    socket =
      assign(socket,
        store_infos: store_infos,
        current_page: "Partners Overview",
        temporary_assigns: []
      )

    {:ok, socket}
  end
end
