defmodule JaangWeb.Admin.Partners.PartnerOrderDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Order.Orders

  def mount(params, _session, socket) do
    IO.puts("Inspecting params")
    IO.inspect(params)
    %{"order_id" => order_id, "store_id" => store_id} = params

    order = Orders.get_order(store_id, order_id)

    socket =
      assign(
        socket,
        current_page: "",
        order: order
      )

    {:ok, socket}
  end
end
