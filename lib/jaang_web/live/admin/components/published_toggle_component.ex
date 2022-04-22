defmodule JaangWeb.Admin.Components.PublishedToggleComponent do
  use JaangWeb, :live_component
  alias Jaang.{Product, ProductManager}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div x-data={"{on: #{@changeset.data.published}}"} class="flex items-center">
      <!-- Enabled: "bg-indigo-600", Not Enabled: "bg-gray-200" -->
      <button x-state:on="Enabled" x-state:off="Not Enabled"
              :class="{'bg-indigo-600': on, 'bg-gray-200': !(on)}"
              @click="on = !on"
              type="button"
              class="bg-gray-200 relative inline-flex flex-shrink-0 h-6 w-11 border-2 border-transparent rounded-full cursor-pointer transition-colors ease-in-out duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" aria-pressed="false" aria-labelledby="product-published-label"
              phx-value-published={"#{!@changeset.data.published}"}
              phx-click="published"
              phx-target={@myself}
              >
        <span class="sr-only">product published</span>
        <!-- Enabled: "translate-x-5", Not Enabled: "translate-x-0" -->
        <span aria-hidden="true"
              :class="{'translate-x-5': on, 'translate-x-0': !(on)}"
              x-state:on="Enabled" x-state:off="Not Enabled"
              class="translate-x-0 pointer-events-none inline-block h-5 w-5 rounded-full bg-white shadow transform ring-0 transition ease-in-out duration-200"></span>
      </button>
      <span class="ml-3" id="annual-billing-label">
        <span class="mr-5 text-sm font-medium text-gray-900">Published?</span>
      </span>
    </div>
    """
  end

  def handle_event("published", %{"published" => published}, socket) do
    # get tags and recipe tags and convert to string format
    tags = Product.build_recipe_tag_name_to_string(socket.assigns.product.tags)
    recipe_tags = Product.build_recipe_tag_name_to_string(socket.assigns.product.recipe_tags)

    {:ok, updated_product} =
      ProductManager.update_product(socket.assigns.product, %{
        published: published,
        tags: tags,
        recipe_tags: recipe_tags
      })

    # new_changeset = Product.changeset(new_product, %{})
    # socket = assign(socket, changeset: new_changeset)

    # If the update succeeds, you must not change the product assigns inside the component.
    # If you do so, the product assigns in the component will get out of sync with the LiveView.
    # Since the LiveView is the source of truth, you should instead tell the LiveView that i
    # the product was updated.

    send(self(), {:updated_product, updated_product})
    {:noreply, socket}
  end
end
