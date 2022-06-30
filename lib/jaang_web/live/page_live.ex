defmodule JaangWeb.PageLive do
  use JaangWeb, :live_view

  @moduledoc """
  Home page "/"
  """

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
