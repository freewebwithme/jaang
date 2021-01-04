defmodule Jaang.Checkout.Carts do
  alias Jaang.{StoreManager, InvoiceManager}
  alias Jaang.Checkout.Order
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
    product_id = String.to_integer(product_id)
    # Check if exisiting cart has same product id
    case Enum.find(existing_line_items, fn line_item -> line_item.product_id == product_id end) do
      nil ->
        IO.puts("No current product in carts")
        # there is no same product in cart just add a product
        existing_line_items = existing_line_items |> Enum.map(&Map.from_struct/1)
        attrs = %{line_items: [cart_attrs | existing_line_items]}
        update_cart(cart, attrs)

      line_item ->
        # Found same product then increase quantity and total price.
        IO.puts("Found a product in cart")
        # exclude same product
        existing_line_items =
          existing_line_items
          |> Enum.filter(fn line_item -> line_item.product_id != product_id end)
          |> Enum.map(&Map.from_struct/1)

        new_quantity = line_item.quantity + quantity
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
          |> Enum.map(&Map.from_struct/1)

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
              |> Enum.map(&Map.from_struct/1)
              |> Enum.map(fn line_item ->
                Map.update!(line_item, :quantity, fn _value -> quantity end)
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
  Count total items in the all carts
  """
  def count_total_item(carts) do
    Enum.reduce(carts, 0, fn cart, acc -> Enum.count(cart.line_items) + acc end)
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

  def data() do
    Dataloader.Ecto.new(Jaang.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
