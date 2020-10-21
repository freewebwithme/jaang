defmodule Jaang.Checkout do
  alias Jaang.StoreManager
  alias Jaang.Checkout.Order
  alias Jaang.Repo
  import Ecto.Query

  @doc """
  Create an empty cart with status :cart
  attrs should include user_id
  """
  def create_cart(user_id, store_id) do
    store = StoreManager.get_store(store_id)

    %Order{
      user_id: user_id,
      total: Money.new(0),
      line_items: [],
      status: :cart,
      store_id: store_id,
      store_name: store.name
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
        {:ok, cart} = create_cart(user.id, user.profile.store_id)
        [cart]
    end
  end

  @doc """
  Used to call in the first app loading to retrieve all carts information that is not checked out.
  """
  def get_all_carts(user_id) do
    Repo.all(from o in Order, where: o.user_id == ^user_id and o.status == :cart)
  end

  def update_cart(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
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
        IO.inspect(product_id)
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

  @doc """
  Count total items in the all carts
  """
  def count_total_item(carts) do
    item_num =
      Enum.map(carts, fn cart ->
        Enum.reduce(cart.line_items, 0, fn line_item, acc -> line_item.quantity + acc end)
      end)

    Enum.sum(item_num)
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
end
