defmodule JaangWeb.Admin.Products.ProductEditDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Product
  alias Jaang.Admin.Product.Products
  alias Jaang.Category.Categories
  alias Jaang.Utility
  alias Jaang.Product.MarketPrice

  def mount(%{"store_id" => store_id, "product_id" => product_id}, _session, socket) do
    product = Products.get_product(store_id, product_id)
    changeset = Product.changeset(product, %{})
    categories = Categories.get_all_categories()
    sub_categories = Categories.list_sub_category(product.category_id)
    # get tags and recipe tags and convert to string format
    tags = Product.build_recipe_tag_name_to_string(product.tags)
    recipe_tags = Product.build_recipe_tag_name_to_string(product.recipe_tags)

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
        on_sale: on_sale
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

  def handle_event("product_update", %{"product" => product_attrs} = params, socket) do
    IO.inspect(params)
    # Compare if category or sub category changed
    %{
      "market_price" => new_mp,
      "category" => %{"category_id" => new_category, "id" => _old_category},
      "sub_category" => %{"sub_category_id" => new_sub, "id" => _old_sub}
    } = product_attrs

    # Add category and sub category info
    category = Categories.get_category(new_category)
    sub_category = Categories.get_sub_category(new_sub)

    product_attrs =
      Map.put(product_attrs, "category_id", category.id)
      |> Map.put("sub_category_id", sub_category.id)
      |> Map.put("category_name", category.name)
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
    IO.inspect(product)
    {:ok, new_product} = Jaang.Product.Products.update_product(product, product_attrs)

    sub_categories = Categories.list_sub_category(new_product.category_id)
    # get tags and recipe tags and convert to string format
    tags = Product.build_recipe_tag_name_to_string(new_product.tags)
    recipe_tags = Product.build_recipe_tag_name_to_string(new_product.recipe_tags)
    changeset = Product.changeset(new_product, %{})

    {market_price, market_sale_price, product_price, product_sale_price, on_sale} =
      get_product_price_info(new_product)

    IO.inspect(market_price)

    socket =
      assign(socket,
        product: new_product,
        changeset: changeset,
        selected_category: new_product.category.id,
        sub_categories: sub_categories,
        selected_sub_category: new_product.sub_category.id,
        tags: tags,
        recipe_tags: recipe_tags,
        market_price: Helpers.display_money(market_price),
        market_sale_price: market_sale_price,
        customer_price: product_price,
        customer_sale_price: product_sale_price,
        on_sale: on_sale
      )
      |> put_flash(:info, "Product updated successfully")

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

  def handle_event("change_image", _, socket) do
    {:noreply, socket}
  end

  def handle_event("delete_image", _, socket) do
    {:noreply, socket}
  end

  def handle_event("add_image", _, socket) do
    {:noreply, socket}
  end
end
