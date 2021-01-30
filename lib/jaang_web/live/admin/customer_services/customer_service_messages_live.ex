defmodule JaangWeb.Admin.CustomerServices.CustomerServiceMessagesLive do
  use JaangWeb, :dashboard_live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, current_page: "Customer Serivce Messages")
    {:ok, socket}
  end
end
