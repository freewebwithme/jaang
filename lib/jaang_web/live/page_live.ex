defmodule JaangWeb.PageLive do
  use JaangWeb, :live_view

  def mount(_params, _session, socket) do
	{:ok, socket}
  end


  #TODO: Implement email subscription

  #def handle_event("validate", params, socket) do

  #end

  #def handle_event("subscribe", params, socket) do

  #end
end
