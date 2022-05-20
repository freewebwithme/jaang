defmodule JaangWeb.TermsConditionLive do
  use JaangWeb, :live_view

  @moduledoc false

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "Terms and Conditions")}
  end
end
