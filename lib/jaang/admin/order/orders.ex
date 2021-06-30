defmodule Jaang.Admin.Order.Orders do
  alias Jaang.Checkout.Order
  import Ecto.Query
  alias Jaang.Repo

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
    query =
      if is_nil(store_id) do
        from(o in Order)
      else
        from(o in Order, where: o.store_id == ^store_id)
      end

    Enum.reduce(criteria, query, fn
      {:paginate, %{page: page, per_page: per_page}}, query ->
        from q in query,
          offset: ^((page - 1) * per_page),
          limit: ^per_page

      {:sort, %{sort_by: sort_by, sort_order: sort_order}}, query ->
        from q in query,
          order_by: [{^sort_order, ^sort_by}]

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

  #! TODO: Change this function for Order
  # def get_unfulfilled_orders(store_id) do
  #  today = Timex.to_date(Timex.now("America/Los_Angeles"))

  #  query =
  #    from o in Order,
  #      where:
  #        o.status not in [:cart, :refunded, :delivered] and
  #          i.delivery_date == ^today,
  #      order_by: i.delivery_order,
  #      join: o in assoc(i, :orders),
  #      where: o.store_id == ^store_id,
  #      preload: [orders: o]

  #  Repo.all(query)
  #  |> Repo.preload(:employees)
  #  |> Repo.preload(user: :profile)
  #  |> Enum.group_by(fn invoice -> invoice.status end)
  # end
end
