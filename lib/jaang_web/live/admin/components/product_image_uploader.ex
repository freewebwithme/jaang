defmodule JaangWeb.Admin.Components.ProductImageUploader do
  use JaangWeb, :live_component
  alias Jaang.Amazon.SimpleS3Upload
  alias Jaang.Admin.Product.Products

  def mount(_params, _session, socket) do
    # For LiveView Upload
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:product_image,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1,
        max_file_size: 4_000_000,
        external: &presign_upload/2,
        progress: &handle_progress/3
      )

    IO.puts("inspecting socket assigns")
    IO.inspect(socket.assigns)
    {:ok, socket}
  end

  def render(assigns) do
    IO.puts("Inspecting assigns")
    IO.inspect(assigns)

    ~L"""
      <div class="space-y-4">
        <div class="aspect-w-3 aspect-h-2">
          <img class="py-2 object-contain shadow-lg rounded-lg"
               src="<%= @image.image_url %>" alt="" />
        </div>

        <div class="flex justify-around items-center">
          <button phx-click="change_image"
                  class="ml-5 bg-white py-2 px-3 border border-gray-300 rounded-md shadow-sm text-sm leading-4 font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">Change</button>
          <button phx-click="delete_image"
                  phx-value-image-id="<%= @image.id %>"
                  class="ml-5 bg-white py-2 px-3 border border-gray-300 rounded-md shadow-sm text-sm leading-4 font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">Delete</button>
        </div>

        <div class="space-y-2">
          <div class="text-lg leading-6 font-medium space-y-1">
            <%= if @image.order == 1 do %>
              <h3 class="text-indigo-600 text-center">Default image</h3>
            <% else %>
              <h3></h3>
            <% end %>
          </div>
        </div>
        <!-- Image uploader  -->
        <div>
          <form phx-submit="add-image" phx-change="validate" phx-target="<%= @myself %>">
            <%= for {_ref, msg} <- @uploads.product_image.errors do %>
              <div class="rounded-md bg-red-50 p-4">
                <div class="flex-1 md:flex md:justify-between">
                  <p class="text-sm text-red-700">
                    <%= Phoenix.Naming.humanize(msg) %>
                  </p>
                </div>
              </div>
            <% end %>
            <%= live_file_input @uploads.product_image%>
            <%= for entry <- @uploads.product_image.entries do %>
              <%= live_img_preview entry, height: 50, class: "mt-2" %>
              <div class="flex justify-between mt-2 mb-2 items-center">
                <div class="flex-grow">
                  <progress class="w-full" max="100" value="<%= entry.progress %>" />
                </div>
                <a href="#" phx-click="cancel-entry" phx-value-ref="<%= entry.ref %>"
                        class="ml-2 flex-shrink-0 bg-white py-2 px-3 border border-gray-300 rounded-md shadow-sm text-sm leading-4 font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                        Cancel
                </a>
                <button type="submit"
                        class="bg-white py-2 px-3 border border-gray-300 rounded-md shadow-sm text-sm leading-4 font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                        Upload
                </button>
              </div>
            <% end %>
          </form>
        </div>
      </div>
    """
  end

  # This validate function is for product image upload
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  # Cancel upload
  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :product_image, ref)}
  end

  def handle_event("change_image", _, socket) do
    {:noreply, socket}
  end

  def handle_event("delete_image", %{"image-id" => image_id}, socket) do
    Products.delete_product_image(image_id)
    # Get product again to force reload product image
    product = Products.get_product(socket.assigns.store_id, socket.assigns.product_id)
    {:noreply, assign(socket, product: product)}
  end

  def handle_event("add-image", _, socket) do
    IO.puts("Add image")
    {:noreply, socket}
  end

  defp presign_upload(entry, socket) do
    #  uploads = socket.assigns.uploads
    bucket = System.fetch_env!("AWS_BUCKET_NAME")
    key = "product-images/#{entry.client_name}"
    region = System.fetch_env!("AWS_REGION")

    config = %{
      region: region,
      access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
    }

    {:ok, fields} =
      SimpleS3Upload.sign_form_upload(config, bucket,
        key: key,
        content_type: entry.client_type,
        max_file_size: entry.product_image.max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{
      uploader: "S3",
      key: key,
      url: "http://#{bucket}.s3.amazonaws.com",
      fields: fields
    }

    {:ok, meta, socket}
  end

  def handle_progress(:product_image, entry, socket) do
    if entry.done? do
      IO.puts("upload completed")
      {[completed_entry], []} = uploaded_entries(socket, :product_image)
      s3_image_url = build_s3_filename(completed_entry.client_name)

      ProductManager.create_product_image(socket.assigns.product, %{
        image_url: s3_image_url,
        order: 1
      })

      socket = socket |> put_flash(:info, "Upload completed")
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  defp build_s3_filename(original_filename) do
    bucket = System.fetch_env!("AWS_BUCKET_NAME")
    key = "product-images/#{original_filename}"
    region = System.fetch_env!("AWS_REGION")

    "https://#{bucket}.s3-#{region}.amazonaws.com/#{key}"
  end
end
