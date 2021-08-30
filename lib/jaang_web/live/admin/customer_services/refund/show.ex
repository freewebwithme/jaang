defmodule JaangWeb.Admin.CustomerServices.RefundLive.Show do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.CustomerServices

  def mount(%{"id" => request_id}, _session, socket) do
    refund_request = CustomerServices.get_refund_request(request_id)

    socket =
      assign(socket, current_page: "Refund request detail")
      |> assign(:refund_request, refund_request)

    {:ok, socket}
  end
end
