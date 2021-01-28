defmodule Jaang.Admin.Invoice.Invoices do
  alias Jaang.{Invoice, Repo}
  import Ecto.Query

  # 1 Get all invoices whose status is submitted, packed, on_the_way, delivered
  # set up per page option
  # set up pagination
  @doc """
  Get all invoices whose status is submitted, packed, on_the_way, delivered
  """
  def get_unfulfilled_invoices() do
    query =
      from i in Invoice,
        where: i.status not in [:cart, :refunded, :delivered]

    Repo.all(query) |> Repo.preload(:orders)
  end

  @doc """
  Returns a list of donations matching the given `criteria`

  Example Criteria:

  [
   paginate: %{page: 2, per_page: 5},
   sort: %{sort_by: :delivery_time, sort_order: :asc}
  ]
  """
  def get_unfulfilled_invoices(criteria) when is_list(criteria) do
    query = from(i in Invoice, where: i.status not in [:cart, :refunded, :delivered])

    Enum.reduce(criteria, query, fn
      {:paginate, %{page: page, per_page: per_page}}, query ->
        from q in query,
          offset: ^((page - 1) * per_page),
          limit: ^per_page

      {:sort, %{sort_by: sort_by, sort_order: sort_order}}, query ->
        from q in query, order_by: [{^sort_order, ^sort_by}]
    end)
    |> Repo.all()
  end
end
