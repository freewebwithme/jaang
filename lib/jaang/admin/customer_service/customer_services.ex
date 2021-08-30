defmodule Jaang.Admin.CustomerServices do
  import Ecto.Query
  alias Jaang.Admin.CustomerService.RefundRequest
  alias Jaang.Repo

  @topic inspect(__MODULE__)

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
        case state == :all do
          true ->
            from(q in query)

          _ ->
            from q in query, where: q.status == ^state
        end

      {:search_by, %{search_by: search_by, search_term: term}}, query ->
        search_by_atom = String.to_atom(search_by)

        case search_by_atom do
          :Email ->
            IO.puts("Search by user email")

            from q in query,
              join: u in assoc(q, :user),
              where: u.email == ^term,
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
