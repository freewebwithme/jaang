defmodule JaangWeb.Admin.Partners.PartnersOverviewLive do
  use JaangWeb, :dashboard_live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, current_page: "Partners Overview")}
  end
end
