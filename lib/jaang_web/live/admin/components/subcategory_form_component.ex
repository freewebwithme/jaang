defmodule JaangWeb.Admin.Components.SubcategoryFormComponent do
  use JaangWeb, :live_component
  alias Jaang.Category.SubCategory
  alias Jaang.Category.Categories

  @moduledoc """
  Subcategory form
  """

  def update(%{sub_category: sub_category} = assigns, socket) do
    changeset = SubCategory.changeset(sub_category, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:can_save, changeset.valid?)}
  end

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"sub_category" => sub_attrs}, socket) do
    if socket.assigns.live_action == :subcategory_add do
      case Categories.create_sub_category(sub_attrs) do
        {:ok, sub_category} ->
          send(self(), {:new_subcategory_added, sub_category})

          {:noreply,
           socket
           |> put_flash(:info, "Subcategory created successfully")
           |> push_patch(to: socket.assigns.return_to, replace: true)}

        {:error, changeset} ->
          {:noreply, socket |> assign(:changeset, changeset)}
      end
    else
      case Categories.update_subcategory(socket.assigns.sub_category, sub_attrs) do
        {:ok, sub_category} ->
          send(self(), {:subcategory_updated, sub_category})

          {:noreply,
           socket
           |> put_flash(:info, "Subcategory updated successfully")
           |> push_patch(to: socket.assigns.return_to, replace: true)}

        {:error, changeset} ->
          {:noreply, socket |> assign(:changeset, changeset)}
      end
    end
  end

  def handle_event(
        "validate",
        %{"sub_category" => sub_attrs},
        %{assigns: %{sub_category: sub_category}} = socket
      ) do
    changeset =
      sub_category
      |> SubCategory.changeset(sub_attrs)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset) |> assign(:can_save, changeset.valid?)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto">
      <div class="border-b pb-3 border-gray-200">
        <h3 class="text-md">Add Sub Category for <span class="font-bold"><%= @category.name %> </span></h3>
        <p class="mt-1 max-w-2xl text-sm text-gray-500">At least Add one sub category for this category, you can add subcategories later</p>
      </div>
      <div>
        <.form let={f} for={@changeset} phx-submit="save" phx-change="validate" phx-target={@myself}>
            <%= hidden_input f, :category_id, value: @category.id %>
          <div class="sm:grid sm:grid-cols-5 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
            <%= label f, :name, class: "block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>
            <div class="mt-1 sm:mt-0 sm:col-span-2">
              <%= text_input f, :name, [phx_debounce: "500", required: true, class: "indigo-text-input"] %>
              <%= error_tag f, :name %>
            </div>
          </div>
          <div class="sm:grid sm:grid-cols-2 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
            <div class="flex">
              <%= if @live_action == :subcategory_add do %>
                <%= submit "Add", [class: (if @can_save, do: "indigo-button", else: "disable-button"), phx_disable_with: "Adding..."] %>
              <% else %>
                <%= submit "Save", [class: (if @can_save, do: "indigo-button", else: "disable-button"), phx_disable_with: "Saving..."] %>
              <% end %>
              <%= live_patch to: @return_to, class: "ml-4 red-button" do %>
                Cancel
              <% end %>
            </div>
          </div>
        </.form>
      </div>
    </div>

    """
  end
end
