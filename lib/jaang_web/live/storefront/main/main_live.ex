defmodule JaangWeb.Live.Storefront.MainLive do
  use JaangWeb, :store_live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
