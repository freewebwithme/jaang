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

        store_info = %{
          store_name: store.name,
          store_logo: store.store_logo,
          num_orders: 99,
          num_refund_request: 13,
          published_products: Enum.count(published_products),
          unpublished_products: Enum.count(unpublished_products),
          shoppers: 3,
          drivers: 10,
          gross_sales: "$89347.94",
          net_income: "$25460.88"
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
