defmodule JaangWeb.CartChannel do
  use Phoenix.Channel
  alias JaangWeb.Resolvers.CartResolver

  def join("cart:" <> user_id, _params, %{assigns: %{current_user: user}} = socket) do
    # check if current user match client user
    IO.puts("Printing user_id #{user_id}")

    if String.to_integer(user_id) == user.id do
      # If authorized, return cart information
      {carts, total_items, total_price} = CartResolver.get_updated_carts(user.id)
      IO.puts("Cart channel join successful")

      socket =
        assign(socket, :carts, carts)
        |> assign(:total_items, total_items)
        |> assign(:total_price, total_price)
        |> assign(:user_id, user_id)

      send(self(), :send_cart)

      # {:ok, %{carts: carts, total_items: total_items, total_price: total_price}, socket}
      {:ok, socket}
    else
      {:error, %{reason: "unauthenticated"}}
    end
  end

  def join("cart:" <> _user_id, _params, _socket) do
    IO.puts("Can't join a channel")
    {:error, %{reason: "unauthenticated"}}
  end

  def handle_info(
        :send_cart,
        socket = %{
          assigns: %{
            carts: carts,
            total_items: total_items,
            total_price: total_price,
            user_id: user_id
          }
        }
      ) do
    IO.inspect("Printing total_items: #{total_items}")
    IO.inspect("Printing total_price: #{total_price}")
    # push(socket, "cart", %{carts: carts, total_items: total_items, total_price: total_price})
    # JaangWeb.Endpoint.broadcast!("cart:" <> user_id, "cart_info", %{
    #  carts: carts,
    #  total_items: total_items,
    #  total_price: total_price
    # })

    broadcast!(socket, "cart:" <> user_id, %{
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
        "get_cart",
        _payload,
        socket = %{assigns: %{carts: carts, total_items: total_items, total_price: total_price}}
      ) do
    IO.puts("Calling handle_in: get cart")

    # broadcast(socket, "get_cart", %{
    #  carts: carts,
    #  total_items: total_items,
    #  total_price: total_price
    # })

    {:reply, {:ok, %{carts: carts, total_items: total_items, total_price: total_price}}, socket}
  end
end
