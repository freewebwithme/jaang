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
  Returns a list of invoice matching the given `criteria`

  Example Criteria:

  [
   paginate: %{page: 2, per_page: 5},
   sort: %{sort_by: :delivery_time, sort_order: :asc}
   filter_by: %{by_state: :submitted}
  ]
  """
  def get_invoices(criteria) when is_list(criteria) do
    query = from(i in Invoice)

    Enum.reduce(criteria, query, fn
      {:user_by, %{user_id: user_id}}, query ->
        from q in query, where: q.user_id == ^user_id

      {:paginate, %{page: page, per_page: per_page}}, query ->
        from q in query,
          offset: ^((page - 1) * per_page),
          limit: ^per_page

      {:sort, %{sort_by: sort_by, sort_order: sort_order}}, query ->
        from q in query, order_by: [{^sort_order, ^sort_by}]

      {:filter_by, %{by_state: state}}, query ->
        case state == :all do
          true ->
            from(q in query)

          _ ->
            from q in query, where: q.status == ^state
        end

      {:search_by, %{search_by: search_by, search_term: term}}, query ->
        search_pattern = "%#{term}%"

        case search_by do
          "Invoice number" ->
            from q in query, where: ilike(q.invoice_number, ^search_pattern)

          _ ->
            query
        end
    end)
    |> Repo.all()
  end

  def get_invoices() do
    Repo.all(Invoice)
  end

  @doc """
  Get invoice by id and preload orders and user information
  """

  def get_invoice(invoice_id) do
    query = from i in Invoice, where: i.id == ^invoice_id
    Repo.one(query) |> Repo.preload([:orders, :user])
  end

  def update_invoice(invoice_id, attrs) do
    invoice = get_invoice(invoice_id)

    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end
end
