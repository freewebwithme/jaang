defmodule JaangWeb.Admin.Products.ProductAddLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.{Product, ProductManager}
  alias Jaang.Amazon.SimpleS3Upload
  alias Jaang.Category.Categories
  alias Jaang.StoreManager
  alias Jaang.Utility
  alias JaangWeb.Admin.Products.ProductDetailLive

  def mount(%{"store_id" => store_id}, _session, socket) do
    changeset = Product.changeset(%Product{}, %{})
    store = StoreManager.get_store(store_id)
    categories = Categories.get_all_categories()

    socket =
      assign(socket,
        current_page: "Add new product",
        store_name: store.name,
        store_id: store_id,
        changeset: changeset,
        image_one: nil,
        image_two: nil,
        image_three: nil,
        market_price: nil,
        select_category?: false,
        selected_category: "",
        selected_sub_category: "",
        can_save: false,
        categories: categories,
        sub_categories: [],
        sub_category_error: true
      )

    # For LiveView Upload
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:product_image_one,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1,
        max_file_size: 4_000_000,
        external: &presign_upload/2,
        progress: &handle_progress_one/3
      )
      |> allow_upload(:product_image_two,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1,
        max_file_size: 4_000_000,
        external: &presign_upload/2,
        progress: &handle_progress_two/3
      )
      |> allow_upload(:product_image_three,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1,
        max_file_size: 4_000_000,
        external: &presign_upload/2,
        progress: &handle_progress_three/3
      )

    {:ok, socket}
  end

  def handle_event(
        "add_product",
        %{"product" => prod_attrs} = params,
        socket
      ) do
    IO.puts("Add product submitted")
    IO.inspect(params)

    %{
      "category" => %{"category_id" => cat_id},
      "sub_category" => %{"sub_category_id" => sub_cat_id},
      "market_price" => market_price
    } = prod_attrs

    # Get category and sub category to put names for the product
    category = Categories.get_category(cat_id)
    sub_category = Categories.get_sub_category(sub_cat_id)

    updated_prod_attrs =
      prod_attrs
      |> Map.put("category_id", category.id)
      |> Map.put("category_name", category.name)
      |> Map.put("sub_category_id", sub_category.id)
      |> Map.put("sub_category_name", sub_category.name)
      |> Map.put("store_name", socket.assigns.store_name)
      # with this original price, We calculate customer price
      |> Map.put("original_price", market_price)
      |> Utility.convert_string_key_to_atom_key()

    IO.inspect(updated_prod_attrs)
    new_product = ProductManager.create_product(updated_prod_attrs)

    # Create product images
    create_product_image(socket.assigns.image_one, 1, new_product)
    create_product_image(socket.assigns.image_two, 2, new_product)
    create_product_image(socket.assigns.image_three, 3, new_product)

    socket =
      push_redirect(
        socket,
        to: Routes.live_path(socket, ProductDetailLive, socket.assigns.store_id, new_product.id),
        replace: true
      )

    {:noreply, socket}
  end

  def handle_event("form_changed", params, socket) do
    IO.puts("form changed")
    IO.inspect(params)

    # _target diplays changed field name
    %{
      "_target" => targets,
      "product" => %{
        "category" => %{"category_id" => new_category_id},
        "sub_category" => %{"sub_category_id" => new_sub_category_id}
      }
    } = params

    # If there is "category" in _target map, update subcategory list
    socket =
      cond do
        Enum.member?(targets, "category_id") ->
          sub_categories = Categories.list_sub_categories(new_category_id)

          assign(socket,
            sub_categories: sub_categories,
            selected_category: new_category_id,
            # set empty string for selected_sub_category when category changed.
            # this will select choose prompt message like "Choose sub category"
            can_save: false,
            sub_category_error: true
          )

        Enum.member?(targets, "sub_category_id") ->
          if new_sub_category_id !== "" do
            # User choose a sub category then change can_save to true
            assign(socket,
              can_save: true,
              selected_sub_category: new_sub_category_id,
              sub_category_error: false
            )
          else
            # Empty sub_category_id means User doesn't select a sub category
            assign(socket, can_save: false, sub_category_error: true)
          end

        true ->
          socket
      end

    {:noreply, socket}
  end

  # This validate function is for product image upload
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  # Cancel upload
  def handle_event("cancel-product-image-one", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :product_image_one, ref)}
  end

  def handle_event("cancel-product-image-two", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :product_image_two, ref)}
  end

  def handle_event("cancel-product-image-three", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :product_image_three, ref)}
  end

  # Add image
  def handle_event("add-product-image-one", _, socket) do
    IO.puts("Add image one")
    consume_uploaded_entries(socket, :product_image_one, fn _meta, _entry -> :ok end)
    {:noreply, socket}
  end

  def handle_event("add-product-image-two", _, socket) do
    IO.puts("Add image two")
    consume_uploaded_entries(socket, :product_image_two, fn _meta, _entry -> :ok end)
    {:noreply, socket}
  end

  def handle_event("add-product-image-three", _, socket) do
    IO.puts("Add image three")
    consume_uploaded_entries(socket, :product_image_three, fn _meta, _entry -> :ok end)
    {:noreply, socket}
  end

  # Upload
  # Keep the uploaded image s3 address in socket's assign
  # And create new ProductImage when submit the form finally
  def handle_progress_one(:product_image_one, entry, socket) do
    if entry.done? do
      IO.puts("image_one upload completed")

      {[completed_entry], []} = uploaded_entries(socket, :product_image_one)

      new_image_one = build_s3_filename(completed_entry.client_name)

      socket =
        socket
        |> assign(image_one: new_image_one)
        |> put_flash(:info, "Upload completed")

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_progress_two(:product_image_two, entry, socket) do
    if entry.done? do
      IO.puts("image_two upload completed")

      {[completed_entry], []} = uploaded_entries(socket, :product_image_two)

      new_image_two = build_s3_filename(completed_entry.client_name)

      socket =
        socket
        |> assign(image_two: new_image_two)
        |> put_flash(:info, "Upload completed")

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_progress_three(:product_image_three, entry, socket) do
    if entry.done? do
      IO.puts("image_three upload completed")

      {[completed_entry], []} = uploaded_entries(socket, :product_image_three)

      new_image_three = build_s3_filename(completed_entry.client_name)

      socket =
        socket
        |> assign(image_three: new_image_three)
        |> put_flash(:info, "Upload completed")

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
        max_file_size: 4_000_000,
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

  defp create_product_image(image_url, order, product) do
    case image_url != nil do
      false ->
        nil

      _ ->
        ProductManager.create_product_image(product, %{image_url: image_url, order: order})
    end
  end
end
