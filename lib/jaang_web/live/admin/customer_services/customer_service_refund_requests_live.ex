defmodule JaangWeb.Admin.CustomerServices.CustomerServiceRefundRequestsLive do
  use JaangWeb, :dashboard_live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, current_page: "Refund Request")
    {:ok, socket}
  end
end
