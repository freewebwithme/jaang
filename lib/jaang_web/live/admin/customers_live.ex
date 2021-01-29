defmodule JaangWeb.Admin.CustomersLive do
  use JaangWeb, :dashboard_live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, current_page: "Customers")
    {:ok, socket}
  end
end
