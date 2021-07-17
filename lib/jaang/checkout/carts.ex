defmodule Jaang.Checkout.Carts do
  alias Jaang.{StoreManager, InvoiceManager}
  alias Jaang.Checkout.Order
  alias Jaang.Product
  alias Jaang.Repo
  import Ecto.Query

  @doc """
  Create an empty cart with status :cart
  attrs should include user_id
  """
  def create_cart(user_id, store_id, invoice_id) do
    store = StoreManager.get_store(store_id)

    %Order{
      user_id: user_id,
      total: Money.new(0),
      line_items: [],
      status: :cart,
      store_id: store_id,
      store_name: store.name,
      store_logo: store.store_logo,
      invoice_id: invoice_id,
      available_checkout: false
    }
    |> Repo.insert()
  end

  def get_cart(user_id, store_id) do
    Repo.get_by(Order, user_id: user_id, status: :cart, store_id: store_id)
  end

  def get_cart(order_id) do
    Repo.get_by(Order, id: order_id)
  end

  @doc """
  Used to call in login or sign up
  to send carts info with session
  """
  def get_all_carts_or_create_new(user) do
    carts = get_all_carts(user.id)

    cond do
      Enum.count(carts) > 0 ->
        carts

      true ->
        # There is no cart found.
        # Create an invoice
        invoice = InvoiceManager.get_or_create_invoice(user.id)
        {:ok, cart} = create_cart(user.id, user.profile.store_id, invoice.id)
        [cart]
    end
  end

  @doc """
  Used to call in the first app loading to retrieve all carts information that is not checked out.
  """
  def get_all_carts(user_id) do
    Repo.all(
      from o in Order, where: o.user_id == ^user_id and o.status == :cart, order_by: o.store_id
    )
    |> Repo.preload(:employees)
  end

  def update_cart(%Order{} = order, attrs) do
    IO.puts("Updating cart")

    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def delete_cart(%Order{} = order) do
    order
    |> Repo.delete!()
  end

  @doc """
  Minimum required attrs %{product_id: id, quantity: 1}
  """
  def add_to_cart(%Order{line_items: []} = cart, cart_attrs) do
    attrs = %{line_items: [cart_attrs]}
    update_cart(cart, attrs)
  end

  def add_to_cart(%Order{line_items: existing_line_items} = cart, cart_attrs) do
    %{product_id: product_id, quantity: quantity} = cart_attrs

    product_id =
      if is_binary(product_id) do
        String.to_integer(product_id)
      end

    # Check if exisiting cart has same product id
    case Enum.find(existing_line_items, fn line_item -> line_item.product_id == product_id end) do
      nil ->
        IO.puts("No current product in carts, This is a new product.")
        # there is no same product in cart just add a product
        existing_line_items =
          existing_line_items
          |> Enum.map(fn line_item ->
            # Check if there is a replacement item in existing line_items
            if(line_item.has_replacement) do
              updated_line_item =
                Map.update!(line_item, :replacement_item, fn value -> Map.from_struct(value) end)

              Map.from_struct(updated_line_item)
            else
              Map.from_struct(line_item)
            end
          end)

        attrs = %{line_items: [cart_attrs | existing_line_items]}
        update_cart(cart, attrs)

      line_item ->
        new_quantity = line_item.quantity + quantity
        # Found same product then increase quantity and total price.
        IO.puts("Found a product in cart")
        # exclude same product
        existing_line_items =
          existing_line_items
          |> Enum.filter(fn line_item -> line_item.product_id != product_id end)
          |> Enum.map(fn line_item ->
            # Check if there is a replacement item in existing line_items
            if(line_item.has_replacement) do
              # if there is replacement item update replacement item's quantity also

              updated_line_item =
                Map.update!(line_item, :replacement_item, fn value ->
                  Map.update!(value, :quantity, fn _value -> new_quantity end)
                  |> Map.from_struct()
                end)

              Map.from_struct(updated_line_item)
            else
              Map.from_struct(line_item)
            end
          end)

        new_cart_attrs = %{product_id: product_id, quantity: new_quantity}
        attrs = %{line_items: [new_cart_attrs | existing_line_items]}
        update_cart(cart, attrs)
    end
  end

  def change_quantity_from_cart(%Order{line_items: existing_line_items} = cart, cart_attrs) do
    %{product_id: product_id, quantity: quantity} = cart_attrs
    product_id = String.to_integer(product_id)

    # Find correct line item that match selected product.
    case Enum.find(existing_line_items, fn line_item -> line_item.product_id == product_id end) do
      nil ->
        IO.puts("Can't find a product in the cart")
        # just return a cart
        {:ok, cart}

      _line_item ->
        # Found same product then change a quantity and total price.
        IO.puts("Found a product in cart")

        # exclude same product
        excluding_line_items =
          existing_line_items
          |> Enum.filter(fn line_item -> line_item.product_id != product_id end)
          |> Enum.map(fn line_item ->
            if(line_item.has_replacement) do
              updated_line_item =
                Map.update!(line_item, :replacement_item, fn value -> Map.from_struct(value) end)

              Map.from_struct(updated_line_item)
            else
              Map.from_struct(line_item)
            end
          end)

        cond do
          quantity == 0 ->
            # User deleted a product from a cart
            # So just return excluded line_items.
            IO.puts("request quantity == 0, so delete a product from cart")
            IO.inspect(excluding_line_items)

            if Enum.count(excluding_line_items) == 0 do
              # There is no item in the cart, delete a cart
              delete_cart(cart)
            else
              attrs = %{line_items: excluding_line_items}
              update_cart(cart, attrs)
            end

          true ->
            # Find product that will be updated from line items
            [line_item] =
              Enum.filter(existing_line_items, fn line_item ->
                line_item.product_id == product_id
              end)
              # |> Enum.map(&Map.from_struct/1)
              |> Enum.map(fn line_item ->
                if(line_item.has_replacement) do
                  updated_line_item =
                    Map.update!(line_item, :replacement_item, fn value ->
                      # if there is replacement item update replacement item's quantity also
                      Map.update!(value, :quantity, fn _value -> quantity end)
                      |> Map.from_struct()
                    end)
                    |> Map.update!(:quantity, fn _value -> quantity end)

                  Map.from_struct(updated_line_item)
                else
                  updated_line_item = Map.update!(line_item, :quantity, fn _value -> quantity end)
                  Map.from_struct(updated_line_item)
                end
              end)

            # Merge updated line_item and excluding_line_items
            # I need to just update existing line items not adding new line items
            # If I just update by adding new line items, line_items' created_at time
            # is reset so I can't order by line_item by created at.
            updated_line_items = [line_item | excluding_line_items]
            # new_cart_attrs = %{product_id: product_id, quantity: quantity}
            attrs = %{line_items: updated_line_items}
            update_cart(cart, attrs)
        end
    end
  end

  @doc """
  Add a note or replacement item
  """
  def add_note_or_replacement_item(
        %Order{line_items: existing_line_items} = cart,
        note,
        replacement_item_id,
        line_item_id
      ) do
    # Changing %LineItem to Map also
    excluding_line_items =
      existing_line_items
      |> Enum.filter(&(&1.id != line_item_id))
      |> Enum.map(fn line_item ->
        if(line_item.has_replacement) do
          updated_line_item =
            Map.update!(line_item, :replacement_item, fn value -> Map.from_struct(value) end)

          Map.from_struct(updated_line_item)
        else
          Map.from_struct(line_item)
        end
      end)

    IO.puts("Inspecting excluding_line_items")
    IO.inspect(excluding_line_items)
    IO.puts("Printing line_item_id: #{line_item_id}")

    [line_item] =
      Enum.filter(existing_line_items, &(&1.id == line_item_id))
      |> Enum.map(&Map.from_struct/1)
      |> Enum.map(fn line_item ->
        IO.puts("Enumerating existing line items")

        if(replacement_item_id == "") do
          # replacemnet_item_id is empty, just update note.
          line_item = line_item |> Map.update!(:note, fn _value -> note end)
          IO.puts("Adding a note")

          updated_line_item =
            if(line_item.has_replacement) do
              # Or if line_item has already replacement_item, then remove it
              IO.puts("Removing replacement item")

              line_item
              |> Map.update!(:replacement_item, fn _value -> nil end)
              |> Map.update!(:has_replacement, fn _value -> false end)
              |> Map.update!(:replacement_id, fn _value -> nil end)
            else
              line_item
            end

          IO.puts("Inspecting line_item in empty replacement id")
          IO.inspect(updated_line_item)
        else
          # Create replacement line_item inside existing line_item
          {product_id, ""} = Integer.parse(replacement_item_id)
          IO.puts("Adding a replacement item")

          Map.update!(line_item, :replacement_id, fn _value -> replacement_item_id end)
          |> Map.update!(:has_replacement, fn _value -> true end)
          |> Map.update!(:replacement_item, fn _value ->
            %{product_id: product_id, quantity: line_item.quantity}
          end)
          |> Map.update!(:note, fn _value -> note end)
        end
      end)

    IO.puts("Inspecting line_item")
    IO.inspect(line_item)

    updated_line_items = [line_item | excluding_line_items]
    update_cart(cart, %{line_items: updated_line_items})
  end

  @doc """
  Count total items in the all carts
  """
  def count_total_item(carts) do
    Enum.reduce(carts, 0, fn cart, acc -> Enum.count(cart.line_items) + acc end)
  end

  def count_total_item(carts, status) do
    Enum.reduce(carts, 0, fn cart, acc ->
      # get only ready items
      ready_items = Enum.filter(cart.line_items, &(&1.status == status))
      Enum.count(ready_items) + acc
    end)
  end

  @doc """
  Calculate total price in the all carts
  """
  def calculate_total_price(carts) do
    Enum.map(carts, fn cart ->
      Enum.reduce(cart.line_items, Money.new(0), fn line_item, acc ->
        Money.add(line_item.total, acc)
      end)
    end)
    |> Enum.reduce(Money.new(0), fn price, acc -> Money.add(price, acc) end)
  end

  @doc """
  This function is called whenever fetch carts(orders).
  I need to check current product price to update line_item
  because price could be changed because of sale event.
  If product is on sale, show sale price
  if not show original price
  params: List of %Order{}
  """
  def refresh_product_price(carts) do
    # Get product_ids from current line item in the cart
    product_ids =
      Enum.map(carts, fn %{line_items: line_items} ->
        Enum.reduce(line_items, [], fn %{product_id: product_id}, acc ->
          [product_id | acc]
        end)
      end)
      |> Enum.flat_map(fn x -> x end)

    # Get all products in carts
    query =
      from p in Product,
        where: p.id in ^product_ids and p.published == true,
        join: pp in assoc(p, :product_prices),
        # on: pp.product_id == p.id,
        where: fragment("now() between ? and ?", pp.start_date, pp.end_date),
        # join: pi in assoc(p, :product_images),
        # on: pi.product_id == p.id,
        preload: [product_prices: pp]

    grouped_products = Repo.all(query) |> Enum.group_by(& &1.id)

    Enum.map(carts, fn %{line_items: line_items} = order ->
      new_line_items = Enum.map(line_items, fn line_item -> Map.from_struct(line_item) end)

      updated_line_items =
        Enum.map(new_line_items, fn line_item ->
          # Get product information from grouped products
          [product] = Map.get(grouped_products, line_item.product_id)
          [product_price] = product.product_prices
          # Just check if product is still on sale or not.
          if(product_price.on_sale == line_item.on_sale) do
            # I don't need a change
            if(line_item.has_replacement) do
              line_item
              |> Map.update!(:replacement_item, fn value ->
                Map.from_struct(value)
              end)
            else
              line_item
            end
          else
            if(line_item.has_replacement) do
              line_item
              |> Map.update!(:replacement_item, fn value -> Map.from_struct(value) end)
              |> Map.update!(:on_sale, fn _value -> product_price.on_sale end)
              |> Map.update!(:discount_percentage, fn _value -> nil end)
              |> Map.update!(:price, fn _value -> product_price.original_price end)
              |> Map.update!(:total, fn _value ->
                Money.multiply(product_price.original_price, line_item.quantity)
              end)
            else
              line_item
              |> Map.update!(:on_sale, fn _value -> product_price.on_sale end)
              |> Map.update!(:discount_percentage, fn _value -> nil end)
              |> Map.update!(:price, fn _value -> product_price.original_price end)
              |> Map.update!(:total, fn _value ->
                Money.multiply(product_price.original_price, line_item.quantity)
              end)
            end
          end
        end)

      attrs = %{line_items: updated_line_items}
      update_cart(order, attrs)
    end)
  end

  def data() do
    Dataloader.Ecto.new(Jaang.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
