defmodule JaangWeb.Admin.DriversLive do
  use JaangWeb, :dashboard_live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, current_page: "Drivers")
    {:ok, socket}
  end
end
