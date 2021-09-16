defmodule Jaang.Admin.CustomerServices do
  import Ecto.Query
  alias Jaang.Admin.CustomerService.{RefundRequest, CustomerMessage}
  alias Jaang.Repo

  @topic inspect(__MODULE__)

  def change_refund_request(%RefundRequest{} = refund_request, attrs) do
    refund_request
    |> RefundRequest.changeset(attrs)
  end

  def add_error_to_customer_services(changeset, key, message) do
    changeset
    |> Ecto.Changeset.add_error(key, message)
  end

  def create_refund_request(attrs) do
    %RefundRequest{}
    |> RefundRequest.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:new_refund_request)
  end

  def list_refund_request(criteria) when is_list(criteria) do
    query = from rr in RefundRequest, order_by: [desc: rr.inserted_at]

    Enum.reduce(criteria, query, fn
      {:paginate, %{page: page, per_page: per_page}}, query ->
        from q in query,
          offset: ^((page - 1) * per_page),
          limit: ^per_page

      {:filter_by, %{by_state: state}}, query ->
        state = state |> String.downcase() |> String.replace(" ", "_") |> String.to_atom()

        case state == :all do
          true ->
            from(q in query)

          _ ->
            from q in query, where: q.status == ^state
        end

      {:search_by, %{search_by: search_by, search_term: term}}, query ->
        search_by_atom = String.to_atom(search_by)
        search_pattern = "%#{term}%"

        case search_by_atom do
          :Email ->
            IO.puts("Search by user email")

            from q in query,
              join: u in assoc(q, :user),
              where: ilike(u.email, ^search_pattern),
              preload: [user: u]

          _ ->
            query
        end
    end)
    |> Repo.all()
    |> Repo.preload([:user, :order])
  end

  def get_refund_request(id) do
    Repo.get_by(RefundRequest, id: id) |> Repo.preload([:order, [user: :profile]])
  end

  def update_refund_request(refund_request, attrs) do
    refund_request
    |> RefundRequest.changeset(attrs)
    |> Repo.update()
  end

  # Customer message
  def change_customer_message(%CustomerMessage{} = customer_message, attrs) do
    customer_message
    |> CustomerMessage.changeset(attrs)
  end

  def create_customer_message(attrs) do
    %CustomerMessage{}
    |> CustomerMessage.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:new_customer_message)
  end

  def list_customer_message(criteria) when is_list(criteria) do
    query = from cm in CustomerMessage, order_by: [desc: cm.inserted_at]

    Enum.reduce(criteria, query, fn
      {:paginate, %{page: page, per_page: per_page}}, query ->
        from q in query,
          offset: ^((page - 1) * per_page),
          limit: ^per_page

      {:filter_by, %{by_state: state}}, query ->
        state = state |> String.downcase() |> String.replace(" ", "_") |> String.to_atom()

        case state == :all do
          true ->
            from(q in query)

          _ ->
            from q in query, where: q.status == ^state
        end

      {:search_by, %{search_by: search_by, search_term: term}}, query ->
        search_by_atom = String.to_atom(search_by)
        search_pattern = "%#{term}%"

        case search_by_atom do
          :Email ->
            IO.puts("Search by user email")

            from q in query,
              join: u in assoc(q, :user),
              where: ilike(u.email, ^search_pattern),
              preload: [user: u]

          _ ->
            query
        end
    end)
    |> Repo.all()
    |> Repo.preload([:user, :order])
  end

  def get_customer_message(id) do
    Repo.get_by(CustomerMessage, id: id)
    |> Repo.preload([[order: :refund_request], [user: :profile]])
  end

  def update_customer_message(customer_message, attrs) do
    customer_message
    |> CustomerMessage.changeset(attrs)
    |> Repo.update()
  end

  def subscribe() do
    IO.puts("Subscribe to #{@topic}")
    Phoenix.PubSub.subscribe(Jaang.PubSub, @topic)
  end

  def subscribe(_), do: :error

  def broadcast({:ok, refund_request}, event) do
    Phoenix.PubSub.broadcast(Jaang.PubSub, @topic, {event, refund_request})
    {:ok, refund_request}
  end

  def broadcast({:error, _reason} = error, _event), do: error
end
