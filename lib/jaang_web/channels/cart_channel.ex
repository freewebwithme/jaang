defmodule JaangWeb.CartChannel do
  use Phoenix.Channel
  alias Jaang.OrderManager

  def join("cart:" <> user_id, _params, %{assigns: %{current_user: user}} = socket) do
    # check if current user match client user
    IO.puts("Printing user_id #{user_id}")

    if String.to_integer(user_id) == user.id do
      # If authorized, return cart information
      {carts, total_items, total_price} = get_updated_carts(user.id)
      IO.puts("Cart channel join successful")

      # send(self(), :send_cart)

      # Send currently saved carts information to client
      {:ok, %{orders: carts, total_items: total_items, total_price: total_price}, socket}
    else
      {:error, %{reason: "unauthenticated"}}
    end
  end

  def join("cart:" <> _user_id, _params, _socket) do
    IO.puts("Can't join a channel")
    {:error, %{reason: "unauthenticated"}}
  end

  def handle_info({:send_cart, event}, %{assigns: %{current_user: user}} = socket) do
    {carts, total_items, total_price} = get_updated_carts(user.id)

    broadcast!(socket, event, %{
      carts: carts,
      total_items: total_items,
      total_price: total_price
    })

    {:noreply, socket}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  def handle_in(
        "add_to_cart",
        payload,
        socket
      ) do
    %{
      "user_id" => user_id,
      "product_id" => product_id,
      "store_id" => store_id,
      "quantity" => quantity
    } = payload

    case OrderManager.get_cart(user_id, store_id) do
      nil ->
        # There is no cart for store.  Create initial carts
        {:ok, cart} = OrderManager.create_cart(user_id, store_id)
        # Add item to cart
        OrderManager.add_to_cart(cart, %{product_id: product_id, quantity: quantity})

      cart ->
        # Add item to cart
        OrderManager.add_to_cart(cart, %{product_id: product_id, quantity: quantity})
    end

    send(self(), {:send_cart, "add_to_cart"})

    {:noreply, socket}
  end

  def get_updated_carts(user_id) do
    carts = OrderManager.get_all_carts(user_id)

    # Extract line items and sort by inserted at
    sorted_carts =
      Enum.map(carts, fn %{line_items: line_items, total: total} = cart ->
        total = Money.to_string(total)
        cart = Map.put(cart, :total, total)
        # Sort the line item by inserted at
        line_items = Enum.sort(line_items, &(&1.inserted_at <= &2.inserted_at))

        # convert %Money{} to string "$13.00"
        line_items =
          Enum.map(line_items, fn line_item ->
            %{price: price, total: total} = line_item
            price = Money.to_string(price)
            total = Money.to_string(total)
            line_item = Map.put(line_item, :price, price) |> Map.put(:total, total)
            line_item
          end)

        Map.put(cart, :line_items, line_items)
      end)

    total_items = OrderManager.count_total_item(sorted_carts)
    # I can't use sorted_carts because it's price and total is converted string
    # so use original carts
    total_price = OrderManager.calculate_total_price(carts)
    {sorted_carts, total_items, Money.to_string(total_price)}
  end
end
