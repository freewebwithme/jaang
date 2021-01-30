defmodule JaangWeb.Admin.CustomerServices.CustomerServicesOverviewLive do
  use JaangWeb, :dashboard_live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, current_page: "Customer Services Overview")
    {:ok, socket}
  end
end
