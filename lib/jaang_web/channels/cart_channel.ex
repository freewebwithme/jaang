defmodule JaangWeb.CartChannel do
  use Phoenix.Channel
  alias Jaang.{AccountManager, OrderManager, InvoiceManager}
  alias Jaang.Checkout.{Calculate, Carts}
  alias Jaang.Invoice.Invoices
  alias Jaang.Notification.OneSignal

  intercept ["new_order"]

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
    IO.puts("Calling :send_cart from cart_channel")

    {carts, total_items, total_price} = get_updated_carts(user.id)

    # broadcast!(socket, event, %{
    #  orders: carts,
    #  total_items: total_items,
    #  total_price: total_price
    # })

    push(socket, event, %{
      orders: carts,
      total_items: total_items,
      total_price: total_price
    })

    {:noreply, socket}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  def handle_out("new_order", _payload, socket) do
    IO.puts("Testing channel")
    {:noreply, socket}
  end

  ### *** Add to cart event ***

  def handle_in(
        "add_to_cart",
        payload,
        socket
      ) do
    IO.puts("add_to_cart handle in called")

    %{
      "user_id" => user_id,
      "product_id" => product_id,
      "store_id" => store_id,
      "quantity" => quantity
    } = payload

    user_id = String.to_integer(user_id)

    # Get a cart for store id
    case OrderManager.get_cart(user_id, store_id) do
      nil ->
        IO.puts("Cant' find a cart. Create a cart with invoice")
        # Get an invoice
        invoice = InvoiceManager.get_or_create_invoice(user_id)
        # There is no cart(order) for this store.  Create initial carts
        {:ok, cart} = OrderManager.create_cart(user_id, store_id, invoice.id)

        # Add item to cart
        case OrderManager.add_to_cart(cart, %{product_id: product_id, quantity: quantity}) do
          {:ok, _order} ->
            {carts, total_items, total_price} = get_updated_carts(user_id)

            broadcast_cart(carts, total_items, total_price, socket)

            {:reply, {:ok, %{orders: carts, total_items: total_items, total_price: total_price}},
             socket}

          {:error, _changeset} ->
            {:reply, :error, socket}

          _ ->
            {:reply, :error, socket}
        end

      cart = %Jaang.Checkout.Order{} ->
        IO.puts("Found a cart, add a product to a cart")
        # Add item to cart
        case OrderManager.add_to_cart(cart, %{product_id: product_id, quantity: quantity}) do
          {:ok, _order} ->
            {carts, total_items, total_price} = get_updated_carts(user_id)
            broadcast_cart(carts, total_items, total_price, socket)

            {:reply, {:ok, %{orders: carts, total_items: total_items, total_price: total_price}},
             socket}

          {:error, _changeset} ->
            {:reply, :error, socket}

          _ ->
            {:reply, :error, socket}
        end

      _ ->
        {:reply, :error, socket}
    end
  end

  ### *** Update cart event ***

  def handle_in("update_cart", payload, socket) do
    %{
      "user_id" => user_id,
      "product_id" => product_id,
      "store_id" => store_id,
      "quantity" => quantity
    } = payload

    IO.puts("update_cart handle in called")
    user_id = String.to_integer(user_id)
    attrs = %{user_id: user_id, product_id: product_id, store_id: store_id, quantity: quantity}

    cart = OrderManager.get_cart(user_id, store_id)

    case OrderManager.change_quantity_from_cart(cart, attrs) do
      {:ok, _order} ->
        # Send updated cart
        {carts, total_items, total_price} = get_updated_carts(user_id)

        broadcast_cart(carts, total_items, total_price, socket)

        {:reply, {:ok, %{orders: carts, total_items: total_items, total_price: total_price}},
         socket}

      # When user delete last line item, I just delete cart and return %Order{}
      %Jaang.Checkout.Order{} = _order ->
        {carts, total_items, total_price} = get_updated_carts(user_id)

        broadcast_cart(carts, total_items, total_price, socket)

        {:reply, {:ok, %{orders: carts, total_items: total_items, total_price: total_price}},
         socket}

      {:error, _changeset} ->
        {:reply, :error, socket}
    end
  end

  def handle_in(
        "add_note_or_replacement_item",
        %{
          "note" => note,
          "replacement_item_id" => replacement_item_id,
          "line_item_id" => line_item_id,
          "user_id" => user_id,
          "store_id" => store_id
        },
        socket
      ) do
    # {replacement_item_id, ""} = Integer.parse(replacement_item_id)
    # Get cart and line item from cart
    cart = OrderManager.get_cart(user_id, store_id)

    case OrderManager.add_note_or_replacement_item(cart, note, replacement_item_id, line_item_id) do
      {:ok, _order} ->
        {carts, total_items, total_price} = get_updated_carts(user_id)

        broadcast_cart(carts, total_items, total_price, socket)

        {:reply, {:ok, %{orders: carts, total_items: total_items, total_price: total_price}},
         socket}

      {:error, _changeset} ->
        {:reply, :error, socket}
    end
  end

  def handle_in("get_cart", _payload, socket) do
    send(self(), {:send_cart, "get_cart"})
    {:noreply, socket}
  end

  ### *** Place an Order ***
  def handle_in("place_an_order", payload, %{assigns: %{current_user: user}} = socket) do
    %{
      "token" => token,
      "order_infos" => order_infos
    } = payload

    IO.puts("Placing an order in Cart channel")
    fetched_user = AccountManager.get_user_by_session_token(token)

    if(user.id == fetched_user.id) do
      # user matches, go ahead process an order
      IO.puts("Inspecting order infos")
      IO.inspect(order_infos)

      # Update order information

      case OrderManager.place_an_order(order_infos, fetched_user) do
        {:ok, invoice} ->
          # Send empty cart
          {carts, total_items, total_price} = get_updated_carts(user.id)

          # Send order confirmation push notification
          OneSignal.create_notification(
            "JaangCart",
            "We received your order and will process soon. Thanks",
            fetched_user.id
          )

          # Broadcast for new invoice
          Invoices.broadcast({:ok, invoice}, :new_invoice)
          # Broadcast for new order
          Enum.map(invoice.orders, fn order ->
            {:ok, order}
            |> Carts.broadcast(:new_order)
            |> Carts.broadcast_to_employee("new_order")
          end)

          # Send invoice id to the flutter to join invoice channel in flutter(Not joining invoice channel currently)
          {:reply,
           {:ok,
            %{
              orders: carts,
              total_items: total_items,
              total_price: total_price,
              invoice_id: invoice.id
            }}, socket}

        {:error, _message} ->
          {:reply, :error, socket}
      end
    else
      {:reply, :error, socket}
    end
  end

  defp broadcast_cart(carts, total_items, total_price, socket) do
    broadcast_from(socket, "cart_updated", %{
      orders: carts,
      total_items: total_items,
      total_price: total_price
    })
  end

  def get_updated_carts(user_id) do
    # Refresh product price in carts
    OrderManager.get_all_carts(user_id) |> OrderManager.refresh_product_price()

    # Get updated cart again
    carts = OrderManager.get_all_carts(user_id)

    # Extract line items and sort by inserted at
    sorted_carts =
      Enum.map(carts, fn %{
                           line_items: line_items,
                           total: _total,
                           required_amount: _required_amount
                         } = cart ->
        # Sort the line item by inserted at
        line_items = Enum.sort(line_items, &(&1.inserted_at <= &2.inserted_at))
        Map.put(cart, :line_items, line_items)
      end)

    total_items = Calculate.count_total_item_all_carts(sorted_carts)
    total_price = Calculate.calculate_total_price(sorted_carts)
    {sorted_carts, total_items, Money.to_string(total_price)}
  end
end
