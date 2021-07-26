defmodule Jaang.Admin.Order.Orders do
  import Ecto.Query
  alias Jaang.Repo

  alias Jaang.Checkout.Order
  alias Jaang.Checkout.Carts
  alias Jaang.Notification.OneSignal

  @doc """
  Returns a list of order matching the given `criteria`

  Example Criteria:

  [
   paginate: %{page: 2, per_page: 5},
   sort: %{sort_by: :delivery_time, sort_order: :asc}
   filter_by: %{by_state: :submitted}
  ]
  """
  def get_orders(store_id \\ nil, criteria) when is_list(criteria) do
    IO.puts("Criteria")
    IO.inspect(criteria)

    query =
      if is_nil(store_id) do
        from(o in Order)
      else
        from(o in Order, where: o.store_id == ^store_id)
      end

    Enum.reduce(criteria, query, fn
      {:user_by, %{user_id: user_id}}, query ->
        from q in query, where: q.user_id == ^user_id

      {:paginate, %{page: page, per_page: per_page}}, query ->
        from q in query,
          offset: ^((page - 1) * per_page),
          limit: ^per_page

      {:sort, %{sort_by: sort_by, sort_order: sort_order}}, query ->
        from q in query,
          order_by: [{^sort_order, ^sort_by}]

      {:search_by, %{search_by: search_by, search_term: term}}, query ->
        IO.puts("Inspecting search term")
        IO.inspect(search_by)
        search_pattern = "%#{term}"
        search_by = String.to_atom(search_by)

        case search_by do
          :"Order id" ->
            IO.puts("search by order id")
            {order_id, _rest} = Integer.parse(term)
            from q in query, where: q.id == ^order_id

          _ ->
            query
        end

      {:filter_by, %{by_state: state}}, query ->
        case state == :all do
          true ->
            from(q in query)

          _ ->
            from q in query, where: q.status == ^state
        end
    end)
    |> Repo.all()
    |> Repo.preload(user: :profile)
  end

  def get_order(store_id, order_id) do
    query =
      from o in Order,
        where: o.store_id == ^store_id and o.id == ^order_id

    Repo.one(query)
  end

  def get_order(order_id) do
    query =
      from o in Order,
        where: o.id == ^order_id

    Repo.one(query)
  end

  def get_unfulfilled_orders(store_id) do
    today = Timex.to_date(Timex.now("America/Los_Angeles"))

    query =
      from o in Order,
        where:
          o.status not in [:cart, :refunded, :delivered] and
            o.delivery_date == ^today and
            o.store_id == ^store_id,
        order_by: o.delivery_order

    Repo.all(query)
    |> Repo.preload(:employees)
    |> Repo.preload(user: :profile)
    |> Enum.group_by(fn invoice -> invoice.status end)
  end

  def update_order_status_and_notify(order_id, status) do
    order = get_order(order_id)

    order
    |> update_and_broadcast_order(status)
    |> send_notification(status)
  end

  defp update_and_broadcast_order(order, status) do
    order
    |> Carts.update_cart(%{status: status})
    |> Carts.broadcast(:order_updated)
  end

  defp send_notification({:ok, order}, status) do
    case status do
      :shopping ->
        OneSignal.create_notification(
          "JaangCart",
          "Our shopper just starts shopping!",
          order.user_id
        )

      # in packed status, do not send notification to client
      :packed ->
        nil

      :on_the_way ->
        OneSignal.create_notification("JaangCart", "Your order is on the way!", order.user_id)

      :delivered ->
        OneSignal.create_notification("JaangCart", "Your order is delivered!", order.user_id)
    end

    {:ok, order}
  end
end
