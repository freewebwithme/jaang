defmodule JaangWeb.Admin.Components.CategoryFormComponent do
  use JaangWeb, :live_component
  alias Jaang.Category.Categories

  @moduledoc """
  Category add/edit form component
  """

  def update(%{category: category} = assigns, socket) do
    changeset = Categories.change_category(category, %{})
    IO.puts("Inspecting changeset")
    IO.inspect(changeset)
    IO.inspect(category)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:can_save, changeset.valid?)}
  end

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto">
      <div class="border-b pb-3 border-gray-200">
        <h3 class="text-lg leading-6 font-medium text-gray-900"><%= @title %></h3>
        <p class="mt-1 max-w-2xl text-sm text-gray-500">Add a category with subcategory</p>
      </div>

      <div class="max-w-2xl">
        <.form let={f} for={@changeset} url="#" phx-submit="save" phx-change="validate" phx-target={@myself} class="space-y-6 sm:space-y-5">
          <div class="sm:grid sm:grid-cols-5 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
            <%= label f, :name, class: "block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>
            <div class="mt-1 sm:mt-0 sm:col-span-2">
              <%= text_input f, :name,
              [phx_debounce: "500",
               required: true,
               class: "mt-1 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"] %>
              <%= error_tag f, :name %>
            </div>
          </div>

          <div class="sm:grid sm:grid-cols-5 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
            <%= label f, :description, class: "block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>
            <div class="mt-1 sm:mt-0 sm:col-span-2">
              <%= textarea f, :description,
              [phx_debounce: "500",
               required: true,
               class: "mt-1 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"] %>
              <%= error_tag f, :description %>
            </div>
          </div>

          <div class="border-b pb-3 border-gray-200">
            <h3 class="text-md">Add Sub Category</h3>
            <p class="mt-1 max-w-2xl text-sm text-gray-500">At least Add one sub category for this category, you can add subcategories later</p>
          </div>

           <%= inputs_for f, :sub_categories, [prepend: [%Jaang.Category.SubCategory{}]], fn sc -> %>
             <div class="sm:grid sm:grid-cols-5 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
              <%= label sc, :name, class: "block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>
               <div class="mt-1 sm:mt-0 sm:col-span-2">
                <%= text_input sc, :name,
                 [phx_debounce: "500",
                  required: true,
                  class: "mt-1 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"] %>
              <%= error_tag sc, :name %>
               </div>
             </div>
           <% end %>

          <div class="sm:grid sm:grid-cols-2 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
            <div class="flex">
              <%= if @live_action == :add do %>
                <%= submit "Save", [
                  class: (if @can_save, do: "indigo-button",
                  else: "disable-button"),
                  phx_disable_with: "Saving..."
                  ]
                %>
              <% else %>
                <%= submit "Edit", [
                  class: (if @can_save, do: "indigo-button",
                  else: "disable-button"),
                  phx_disable_with: "Editing...",
                  ]
                %>

              <% end %>
                <%= live_redirect to: @return_to,
                  class: "ml-4 red-button"
                  do %>
                  Cancel
                <% end %>
            </div>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  def handle_event(
        "validate",
        %{"category" => category_attrs},
        %{assigns: %{category: category}} = socket
      ) do
    changeset =
      category
      |> Categories.change_category(category_attrs)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset) |> assign(:can_save, changeset.valid?)}
  end

  def handle_event("save", %{"category" => category_attrs}, socket) do
    case Categories.create_category(category_attrs) do
      {:ok, category} ->
        send(self(), {:new_category, category})

        {:noreply,
         socket
         |> put_flash(:info, "New Category added successfully")
         |> push_patch(to: socket.assigns.return_to, replace: true)}

      {:error, changeset} ->
        {:noreply, socket |> assign(:changeset, changeset)}
    end
  end
end
