defmodule JaangWeb.Admin.CustomerServices.RefundLive.Show do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.CustomerServices

  def mount(%{"id" => _request_id}, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => request_id}, _url, socket) do
    refund_request = CustomerServices.get_refund_request(request_id)

    socket =
      assign(socket, current_page: "Refund request detail")
      |> assign(:refund_request, refund_request)

    {:noreply, socket}
  end
end
