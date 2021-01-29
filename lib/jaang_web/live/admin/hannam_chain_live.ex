defmodule JaangWeb.Admin.HannamChainLive do
  use JaangWeb, :dashboard_live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, current_page: "Hannam")
    {:ok, socket}
  end
end
