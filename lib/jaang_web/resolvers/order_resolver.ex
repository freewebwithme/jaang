defmodule JaangWeb.Resolvers.OrderResolver do
  alias Jaang.{AccountManager, InvoiceManager, OrderManager}
  alias Jaang.Admin.Order.LineItems
  alias Jaang.Admin.CustomerServices

  def fetch_invoices(_, %{token: user_token, limit: limit, offset: offset}, _) do
    user = AccountManager.get_user_by_session_token(user_token)
    invoices = InvoiceManager.get_invoices(user.id, limit, offset)
    {:ok, invoices}
  end

  def request_refund(
        _,
        %{token: token, order_id: order_id, refund_items: refund_items},
        _
      ) do
    user = AccountManager.get_user_by_session_token(token)

    # get order
    order = OrderManager.get_cart(order_id)

    IO.puts("Inspecting refund items")
    IO.inspect(refund_items)

    refund_items_ids = LineItems.get_ids_from_refund_items_map(refund_items)

    case user.id == order.user_id do
      true ->
        refund_items_maps =
          LineItems.filter_line_item_by_ids(order, refund_items_ids)
          |> LineItems.convert_line_item_to_map()

        # Update refund_items_maps using client's requested value
        updated_refund_items = LineItems.update_line_item_maps(refund_items_maps, refund_items)
        # create RefundRequest
        attrs = %{
          status: :not_completed,
          user_id: order.user_id,
          order_id: order.id,
          refund_items: updated_refund_items
        }

        CustomerServices.create_refund_request(attrs)
        {:ok, order}

      _ ->
        {:error, "User doesn't match"}
    end
  end

  def contact_customer_service(_, %{token: token, order_id: order_id, message: message} = args, _) do
    IO.inspect(args)
    user = AccountManager.get_user_by_session_token(token)

    # create customer message
    case CustomerServices.create_customer_message(%{
           status: :new_request,
           message: message,
           user_id: user.id,
           order_id: order_id
         }) do
      {:ok, _customer_message} ->
        {:ok, %{received: true}}

      {:error, _changeset} ->
        {:ok, %{received: false}}
    end
  end
end
