defmodule JaangWeb.ReturnLive do
  use JaangWeb, :live_view

  @moduledoc false

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "Return Policy")}
  end
end
