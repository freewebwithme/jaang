defmodule Jaang.Admin.Invoice.Invoices do
  alias Jaang.{Invoice, Repo}
  import Ecto.Query
  alias Jaang.Invoice.Invoices
  alias Jaang.InvoiceManager
  alias Jaang.Checkout.Calculate
  alias Jaang.StripeManager

  # 1 Get all invoices whose status is submitted, packed, on_the_way, delivered
  # set up per page option
  # set up pagination
  @doc """
  Get all invoices whose status is submitted, packed, on_the_way, delivered.
  Returns invoice list groupbed by status
  There will be only one order because I filters with store_id
  """
  def get_unfulfilled_invoices(store_id) do
    today = Timex.to_date(Timex.now("America/Los_Angeles"))

    query =
      from i in Invoice,
        where:
          i.status not in [:cart, :refunded, :delivered] and
            i.delivery_date == ^today,
        order_by: i.delivery_order,
        join: o in assoc(i, :orders),
        where: o.store_id == ^store_id,
        preload: [orders: o]

    Repo.all(query)
    |> Repo.preload(:employees)
    |> Repo.preload(user: :profile)
    |> Enum.group_by(fn invoice -> invoice.status end)
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
    query = from i in Invoice, order_by: [desc: i.inserted_at]

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
    |> Repo.preload([:orders, user: [:profile]])
  end

  def get_invoices() do
    Repo.all(Invoice)
  end

  @doc """
  Get invoice by id and preload orders and user information
  """

  def get_invoice(invoice_id) do
    query = from i in Invoice, where: i.id == ^invoice_id
    Repo.one(query) |> Repo.preload([[orders: :employees], [user: :profile]])
  end

  @doc """
  Update invoice with photo urls
  Convert list of string photo_urls to
  photo_urls = [%{photo_url: ""}]
  """
  def update_invoice_with_receipt_photos(invoice_id, photo_urls) do
    converted_photo_urls =
      Enum.map(photo_urls, fn photo_url ->
        %{photo_url: photo_url}
      end)

    attrs = %{receipt_photos: converted_photo_urls}

    invoice = get_invoice(invoice_id)

    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  def update_invoice_and_notify(invoice_id, attrs) do
    invoice = get_invoice(invoice_id)

    invoice
    |> update_and_broadcast_invoice(attrs)
  end

  defp update_and_broadcast_invoice(invoice, attrs) do
    invoice
    |> InvoiceManager.update_invoice(attrs)
    |> Invoices.broadcast(:invoice_updated)
  end

  def build_invoice_status(invoice_id) do
    invoice = get_invoice(invoice_id)
    total_orders = Enum.count(invoice.orders)

    if(total_orders <= 1) do
      Enum.reduce(invoice.orders, "", fn order, acc ->
        Atom.to_string(order.status) <> acc
      end)
    else
      Enum.with_index(invoice.orders)
      |> Enum.reduce_while("", fn {order, index}, acc ->
        IO.inspect(acc)

        if index < total_orders do
          if(index == total_orders - 1) do
            {:cont, acc <> Atom.to_string(order.status)}
          else
            {:cont, Atom.to_string(order.status) <> ", " <> acc}
          end
        else
          {:halt, acc}
        end
      end)
    end
  end

  @doc """
  Get invoice and finalize invoice
  1. Recalculate grand total price and total items and invoice status
  2. If all order in invoice has `finalized == true` then capture the payment
  """
  def finalize_invoice(order) do
    invoice = get_invoice(order.invoice_id)
    # Calculate all order's total
    grand_total_price = Calculate.calculate_grand_final_for_invoice(invoice)
    invoice_total_items = Calculate.count_all_total_items(invoice)

    # update invoice also
    invoice_status = build_invoice_status(order.invoice_id)

    invoice_attrs = %{
      grand_total_price: grand_total_price,
      status: invoice_status,
      total_items: invoice_total_items
    }

    {:ok, invoice} = update_invoice_and_notify(order.invoice_id, invoice_attrs)

    # Get all finalized status of order
    all_finalized? =
      Enum.map(invoice.orders, fn order ->
        order.finalized
      end)
      |> Enum.all?()

    if(all_finalized?) do
      # all order is finalized go ahead capture the payment
      case StripeManager.capture_payment_intent(
             invoice.pm_intent_id,
             invoice.grand_total_price.amount
           ) do
        {:ok, _} ->
          {:ok, invoice}

        {:error, error} ->
          {:error, error}
      end
    else
      {:ok, invoice}
    end
  end
end
