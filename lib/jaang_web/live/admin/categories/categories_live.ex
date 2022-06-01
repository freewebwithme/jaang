defmodule JaangWeb.Admin.Categories.CategoriesLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Category.Categories
  alias Jaang.Category

  @moduledoc false

  def mount(_params, _session, socket) do
    categories = Categories.list_categories()

    {:ok,
     socket
     |> assign(:current_page, "Categories")
     |> assign(:categories, categories)}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def handle_info({:new_category, category}, socket) do
    updated_categories = [category | socket.assigns.categories]
    {:noreply, socket |> assign(:categories, updated_categories)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Category List")
  end

  defp apply_action(socket, :add, _params) do
    socket
    |> assign(:page_title, "Add a Category")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :show, %{"category_id" => id}) do
    category = Categories.get_category(id)

    socket
    |> assign(:page_title, "Category detail")
    |> assign(:category, category)
  end
end
