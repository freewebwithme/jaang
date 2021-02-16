defmodule JaangWeb.Admin.Products.ProductEditDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Product
  alias Jaang.Admin.Product.Products
  alias Jaang.Category.Categories
  alias Jaang.Utility
  alias Jaang.Product.MarketPrice
  alias Jaang.ProductManager
  alias Jaang.Amazon.SimpleS3Upload
  alias JaangWeb.Admin.Components.PublishedToggleComponent
  alias JaangWeb.Admin.Products.ProductDetailLive

  def mount(%{"store_id" => store_id, "product_id" => product_id}, _session, socket) do
    product = Products.get_product(store_id, product_id)
    changeset = Product.changeset(product, %{})
    categories = Categories.get_all_categories()
    sub_categories = Categories.list_sub_category(product.category_id)
    # get tags and recipe tags and convert to string format
    tags = Product.build_recipe_tag_name_to_string(product.tags)
    recipe_tags = Product.build_recipe_tag_name_to_string(product.recipe_tags)

    # Get product images
    %{image_one: image_one, image_two: image_two, image_three: image_three} =
      get_product_images(product.product_images)

    {market_price, market_sale_price, product_price, product_sale_price, on_sale} =
      get_product_price_info(product)

    socket =
      assign(socket,
        current_page: "Edit Product detail",
        product_id: product.id,
        store_id: store_id,
        product: product,
        changeset: changeset,
        categories: categories,
        selected_category: product.category.id,
        sub_categories: sub_categories,
        selected_sub_category: product.sub_category.id,
        tags: tags,
        recipe_tags: recipe_tags,
        can_save: true,
        sub_category_error: false,
        market_price: market_price,
        market_sale_price: market_sale_price,
        customer_price: product_price,
        customer_sale_price: product_sale_price,
        on_sale: on_sale,
        image_one: image_one,
        image_two: image_two,
        image_three: image_three
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

  def get_product_price_info(product) do
    [market_price] = Enum.map(product.market_prices, & &1.original_price)
    [market_sale_price] = Enum.map(product.market_prices, & &1.sale_price)
    [product_price] = Enum.map(product.product_prices, & &1.original_price)
    [product_sale_price] = Enum.map(product.product_prices, & &1.sale_price)
    [on_sale] = Enum.map(product.market_prices, & &1.on_sale)

    {market_price, market_sale_price, product_price, product_sale_price, on_sale}
  end

  # Message from PublishedToggle Component about updated published state
  def handle_info({:updated_product, updated_product}, socket) do
    new_changeset = Product.changeset(updated_product, %{})
    socket = assign(socket, changeset: new_changeset)
    {:noreply, socket}
  end

  # Save the form
  def handle_event("product_update", %{"product" => product_attrs} = params, socket) do
    IO.inspect(params)
    # Compare if category or sub category changed
    %{
      "id" => product_id,
      "store_id" => store_id,
      "market_price" => new_mp,
      "category" => %{"category_id" => new_category, "id" => _old_category},
      "sub_category" => %{"sub_category_id" => new_sub, "id" => _old_sub}
    } = product_attrs

    # Add category and sub category info
    category = Categories.get_category(new_category)
    sub_category = Categories.get_sub_category(new_sub)

    product_attrs =
      Map.put(product_attrs, "category_id", category.id)
      |> Map.put("category_name", category.name)
      |> Map.put("sub_category_id", sub_category.id)
      |> Map.put("sub_category_name", sub_category.name)

    # Add market price
    [market_price] = socket.assigns.product.market_prices
    {:ok, new_price} = Money.parse(new_mp)

    price_changed = Utility.price_changed?(market_price, new_price)
    IO.inspect(price_changed)

    if(price_changed) do
      IO.puts("Price changed")
      # Price is changed, create new Market Price
      MarketPrice.create_market_price_with_product_price(
        socket.assigns.product.id,
        %{
          original_price: new_price
        }
      )
    end

    IO.puts("Updated product_attrs")
    IO.inspect(product_attrs)
    product = Products.get_product(socket.assigns.store_id, socket.assigns.product_id)
    ProductManager.update_product(product, product_attrs)
    # Get updated product
    new_product = Products.get_product(store_id, product_id)
    sub_categories = Categories.list_sub_category(new_product.category_id)
    # get tags and recipe tags and convert to string format
    tags = Product.build_recipe_tag_name_to_string(new_product.tags)
    recipe_tags = Product.build_recipe_tag_name_to_string(new_product.recipe_tags)
    changeset = Product.changeset(new_product, %{})

    {market_price, market_sale_price, product_price, product_sale_price, on_sale} =
      get_product_price_info(new_product)

    socket =
      assign(socket,
        product: new_product,
        changeset: changeset,
        selected_category: new_product.category.id,
        sub_categories: sub_categories,
        selected_sub_category: new_product.sub_category.id,
        tags: tags,
        recipe_tags: recipe_tags,
        market_price: market_price,
        market_sale_price: market_sale_price,
        customer_price: product_price,
        customer_sale_price: product_sale_price,
        on_sale: on_sale
      )
      |> put_flash(:info, "Product updated successfully")

    socket =
      push_redirect(socket,
        to:
          Routes.live_path(
            socket,
            ProductDetailLive,
            socket.assigns.store_id,
            new_product.id
          )
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
        "category" => %{"id" => _old_id, "category_id" => new_category_id},
        "sub_category" => %{"id" => _old_sub_id, "sub_category_id" => new_sub_category_id}
      }
    } = params

    # If there is "category" in _target map, update subcategory list
    socket =
      cond do
        Enum.member?(targets, "category_id") ->
          sub_categories = Categories.list_sub_category(new_category_id)

          assign(socket,
            sub_categories: sub_categories,
            selected_category: new_category_id,
            # set empty string for selected_sub_category when category changed.
            # this will select choose prompt message like "Choose sub category"
            selected_sub_category: "",
            can_save: false,
            sub_category_error: true
          )

        Enum.member?(targets, "sub_category_id") ->
          if new_sub_category_id !== "" do
            IO.puts("Change can_save status")
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

  def handle_event("delete_image", %{"image-id" => image_id}, socket) do
    Products.delete_product_image(image_id)
    # Get product again to force reload product image
    product = Products.get_product(socket.assigns.store_id, socket.assigns.product_id)
    # Get product images again
    %{image_one: image_one, image_two: image_two, image_three: image_three} =
      get_product_images(product.product_images)

    {:noreply,
     assign(socket,
       product: product,
       image_one: image_one,
       image_two: image_two,
       image_three: image_three
     )}
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

  def handle_progress_one(:product_image_one, entry, socket) do
    if entry.done? do
      IO.puts("image_one upload completed")
      # Check if image one exist
      # Delete if image_one is not nil
      if socket.assigns.image_one != nil do
        Products.delete_product_image(socket.assigns.image_one.id)
      end

      {[completed_entry], []} = uploaded_entries(socket, :product_image_one)
      # Create product image and link to product
      create_product_image_with_upload(completed_entry.client_name, socket.assigns.product, 1)

      # Get product again to reload associations
      new_product = Products.get_product(socket.assigns.store_id, socket.assigns.product.id)
      # Get product images again
      %{image_one: image_one, image_two: _image_two, image_three: _image_three} =
        get_product_images(new_product.product_images)

      socket =
        socket
        |> assign(product: new_product)
        |> assign(image_one: image_one)
        |> put_flash(:info, "Upload completed")

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_progress_two(:product_image_two, entry, socket) do
    if entry.done? do
      IO.puts("image_two upload completed")
      # Check if image two exist
      # Delete if image_two is not nil
      if socket.assigns.image_two != nil do
        Products.delete_product_image(socket.assigns.image_two.id)
      end

      {[completed_entry], []} = uploaded_entries(socket, :product_image_two)

      # Create product image and link to product
      create_product_image_with_upload(completed_entry.client_name, socket.assigns.product, 2)

      # Get product again to reload associations
      new_product = Products.get_product(socket.assigns.store_id, socket.assigns.product.id)
      # Get product images again
      %{image_one: _image_one, image_two: image_two, image_three: _image_three} =
        get_product_images(new_product.product_images)

      socket =
        socket
        |> assign(product: new_product)
        |> assign(image_two: image_two)
        |> put_flash(:info, "Upload completed")

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_progress_three(:product_image_three, entry, socket) do
    if entry.done? do
      IO.puts("image_three upload completed")
      # Check if image three exist
      # Delete if image_three is not nil
      if socket.assigns.image_three != nil do
        Products.delete_product_image(socket.assigns.image_three.id)
      end

      {[completed_entry], []} = uploaded_entries(socket, :product_image_three)

      # Create product image and link to product
      create_product_image_with_upload(completed_entry.client_name, socket.assigns.product, 3)

      # Get product again to reload associations
      new_product = Products.get_product(socket.assigns.store_id, socket.assigns.product.id)
      # Get product images again
      %{image_one: _image_one, image_two: _image_two, image_three: image_three} =
        get_product_images(new_product.product_images)

      socket =
        socket
        |> assign(product: new_product)
        |> assign(image_three: image_three)
        |> put_flash(:info, "Upload completed")

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  defp create_product_image_with_upload(client_name, product, order) do
    s3_image_url = build_s3_filename(client_name)

    ProductManager.create_product_image(product, %{
      image_url: s3_image_url,
      order: order
    })
  end

  defp build_s3_filename(original_filename) do
    bucket = System.fetch_env!("AWS_BUCKET_NAME")
    key = "product-images/#{original_filename}"
    region = System.fetch_env!("AWS_REGION")

    "https://#{bucket}.s3-#{region}.amazonaws.com/#{key}"
  end

  defp get_product_images(product_images) do
    # Get product images
    Enum.reduce(product_images, %{image_one: nil, image_two: nil, image_three: nil}, fn image,
                                                                                        acc ->
      cond do
        image.order == 1 -> Map.put(acc, :image_one, image)
        image.order == 2 -> Map.put(acc, :image_two, image)
        image.order == 3 -> Map.put(acc, :image_three, image)
      end
    end)
  end
end
