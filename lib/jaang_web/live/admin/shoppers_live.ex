defmodule JaangWeb.Admin.ShoppersLive do
  use JaangWeb, :dashboard_live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, current_page: "Shoppers")
    {:ok, socket}
  end
end
