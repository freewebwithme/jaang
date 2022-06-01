defmodule JaangWeb.Admin.Components.PartnerFormComponent do
  use JaangWeb, :live_component
  alias Jaang.StoreManager
  alias Jaang.Amazon.SimpleS3Upload

  @moduledoc """
  Form component for adding partner
  """

  @max_file_size 4_000_000
  @bucket System.get_env("AWS_BUCKET_NAME")
  @region System.get_env("AWS_REGION")
  @access_key_id System.get_env("AWS_ACCESS_KEY_ID")
  @secret_access_key System.get_env("AWS_SECRET_ACCESS_KEY")

  def update(%{store: store} = assigns, socket) do
    changeset = StoreManager.change_store(store, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:can_save, changeset.valid?)}
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:store_logo,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       max_file_size: @max_file_size,
       external: &presign_upload/2,
       progress: &handle_progress/3
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto">
      <div class="border-b pb-3 border-gray-200">
        <h3 class="text-lg leading-6 font-medium text-gray-900"><%= @title %></h3>
        <p class="mt-1 max-w-2xl text-sm text-gray-500">This information will be displayed in admin site and also in mobile app </p>
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
              <%= text_input f, :description,
              [phx_debounce: "500",
               required: true,
               class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md"] %>
              <%= error_tag f, :description %>
            </div>
          </div>
          <div class="sm:grid sm:grid-cols-5 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
            <%= label f, :price_info, class: "block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>
            <div class="mt-1 sm:mt-0 sm:col-span-2">
              <%= text_input f, :price_info,
              [phx_debounce: "500",
               required: true,
               class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md"] %>
              <%= error_tag f, :price_info %>
            </div>
          </div>
          <div class="sm:grid sm:grid-cols-5 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
            <%= label f, :available_hours, class: "block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>
            <div class="mt-1 sm:mt-0 sm:col-span-2">
              <%= textarea f, :available_hours,
              [phx_debounce: "500",
               required: true,
               class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md"] %>
              <%= error_tag f, :available_hours %>
            </div>
          </div>
          <div class="sm:grid sm:grid-cols-5 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
            <%= label f, :address, class: "block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>
            <div class="mt-1 sm:mt-0 sm:col-span-2">
              <%= text_input f, :address,
              [phx_debounce: "500",
               required: true,
               class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md"] %>
              <%= error_tag f, :address %>
            </div>
          </div>

          <div class="sm:grid sm:grid-cols-5 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
            <%= label f, :phone_number, class: "block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>
            <div class="mt-1 sm:mt-0 sm:col-span-2">
              <%= text_input f, :phone_number,
              [phx_debounce: "500",
               required: true,
               class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md"] %>
              <%= error_tag f, :phone_number %>
            </div>
          </div>

          <div class="sm:grid sm:grid-cols-5 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5" phx-drop-target={@uploads.store_logo.ref}>
            <%= label f, :store_logo, class: "block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>
            <div class="mt-1 sm:mt-0 sm:col-span-2">
            <%# if live action is edit, show current logo image %>
              <%= if @live_action == :edit do %>
               <div class="flex items-center pb-3">
                <div class="flex-shrink-0 h-16 w-16">
                  <img class="h-16 w-16 rounded-full" src={"#{@store.store_logo}"} alt="Store logo">
                </div>
                <p class="pl-3 text-sm text-indigo-500">Current logo</p>
               </div>
              <% end %>
                <%= for entry <- @uploads.store_logo.entries do %>
                  <div class="flex items-center">
                    <%= live_img_preview entry, class: "inline-block h-16 w-16 rounded-full" %>
                    <p class="pl-3 text-sm text-red-500">Logo preview</p>
                    <div class="ml-2">
                      <button type="button" phx-click="delete-upload" phx-value-ref={entry.ref} phx-target={@myself} class="inline-flex items-center p-1 border border-transparent rounded-full shadow-sm text-white bg-orange-600 hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                      </button>
                    </div>
                  <%# errors %>
                  <%= for err <- upload_errors(@uploads.store_logo, entry) do %>
                    <p class="mb-3 text-sm text-red-600 mt-3 ml-1"><%= error_to_string(err) %></p>
                  <% end %>
                  </div>
                <% end %>
                  <div class="mt-3 sm:mt-0">
                    <%= live_file_input(@uploads.store_logo) %>
                    <%= error_tag f, :store_logo %>
                  </div>
            </div>
          </div>

          <div class="sm:grid sm:grid-cols-2 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
            <div class="flex">
              <%= if @live_action == :add do %>
                <%= submit "Save", [
                  class: (if @can_save, do: "relative inline-flex items-center px-6 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:ml-3",
                  else: "relative inline-flex items-center px-6 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-gray-500 bg-gray-300 hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"),
                  phx_disable_with: "Saving..."
                  ]
                %>
              <% else %>
                <%= submit "Edit", [
                  class: (if @can_save, do: "relative inline-flex items-center px-6 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:ml-3",
                  else: "relative inline-flex items-center px-6 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-gray-500 bg-gray-300 hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"),
                  phx_disable_with: "Editing...",
                  ]
                %>

              <% end %>
                <%= live_redirect to: @return_to,
                  class: "ml-4 relative inline-flex items-center px-6 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
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
        %{"store" => store_attrs} = _params,
        %{assigns: %{store: store}} = socket
      ) do
    # :store_logo field is not included in form because
    # `live_file_input` is not allowed to set `id` field
    # So I do check if socket.assigns.uploads has entries for store_log and
    # also check if there is no errors relate to image field
    updated_store_attrs =
      if Enum.empty?(socket.assigns.uploads.store_logo.entries) == false &&
           Enum.empty?(socket.assigns.uploads.store_logo.errors) == true do
        # Image is valid, generate random string for store_log url to pass changeset validation temporarily
        # and update :store_log field with uploaded, valid store_logo url when Form is saved.
        store_attrs |> Map.put("store_logo", UUID.uuid1())
      else
        store_attrs
      end

    changeset =
      store
      |> StoreManager.change_store(updated_store_attrs)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset) |> assign(:can_save, changeset.valid?)}
  end

  def handle_event("save", %{"store" => attrs}, socket) do
    if socket.assigns.live_action == :add do
      {[completed_entry], []} = uploaded_entries(socket, :store_logo)
      s3_file_name = build_s3_filename(completed_entry.client_name)
      # Update "store_logo" value with real s3 url
      updated_attrs = attrs |> Map.put("store_logo", s3_file_name)

      case StoreManager.create_store(updated_attrs) do
        {:ok, store} ->
          send(self(), {:new_partner_added, store})

          {:noreply,
           socket
           |> put_flash(:info, "New partner created successfully")
           |> push_patch(to: socket.assigns.return_to, replace: true)}

        {:error, changeset} ->
          {:noreply, socket |> assign(:changeset, changeset)}
      end
    else
      if Enum.empty?(socket.assigns.uploads.store_logo.entries) do
        IO.puts("No updating logo")
        IO.inspect(socket.assigns.return_to)

        case StoreManager.update_store(socket.assigns.store, attrs) do
          {:ok, store} ->
            send(self(), {:partner_info_updated, store})

            {:noreply,
             socket
             |> put_flash(:info, "Partner information updated successfully")
             |> push_patch(to: socket.assigns.return_to, replace: true)}

          {:error, changeset} ->
            {:noreply, socket |> assign(:changeset, changeset)}
        end
      else
        IO.puts("Updating logo too")
        {[completed_entry], []} = uploaded_entries(socket, :store_logo)
        s3_file_name = build_s3_filename(completed_entry.client_name)
        # Update "store_logo" value with real s3 url
        updated_attrs = attrs |> Map.put("store_logo", s3_file_name)

        case StoreManager.update_store(socket.assigns.store, updated_attrs) do
          {:ok, store} ->
            send(self(), {:partner_info_updated, store})

            {:noreply,
             socket
             |> put_flash(:info, "Partner information updated successfully")
             |> push_patch(to: socket.assigns.return_to, replace: true)}

          {:error, changeset} ->
            {:noreply, socket |> assign(:changeset, changeset)}
        end
      end
    end
  end

  def handle_event("delete-upload", %{"ref" => ref}, socket) do
    IO.puts("delete upload")

    {:noreply, cancel_upload(socket, :store_logo, ref)}
  end

  def error_to_string(:too_large), do: "Image file is too large."
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def error_to_string(:too_many_files), do: "You have selected too many files "
  def error_to_string(:external_client_failure), do: "Can't upload image, please try again"

  defp handle_progress(:store_logo, entry, socket) do
    if entry.done? do
      IO.puts("Store logo upload completed")

      # {[completed_entry], []} = uploaded_entries(socket, :store_logo)
      socket =
        socket
        |> put_flash(:info, "Store logo uploaded successfully")

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  defp presign_upload(entry, socket) do
    IO.puts("Running presign_upload function")

    key = "store-logos/#{entry.client_name}"

    config = %{
      region: @region,
      access_key_id: @access_key_id,
      secret_access_key: @secret_access_key
    }

    {:ok, fields} =
      SimpleS3Upload.sign_form_upload(config, @bucket,
        key: key,
        content_type: entry.client_type,
        max_file_size: @max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{
      uploader: "S3",
      key: key,
      url: "http://#{@bucket}.s3.amazonaws.com",
      fields: fields
    }

    IO.puts("Finishing presign_upload function")
    {:ok, meta, socket}
  end

  defp build_s3_filename(original_filename) do
    key = "store-logos/#{original_filename}"
    "https://#{@bucket}.s3-#{@region}.amazonaws.com/#{key}"
  end
end
