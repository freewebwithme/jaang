defmodule Jaang.Admin.Customer.Customers do
  alias Jaang.Repo
  alias Jaang.Account.User
  import Ecto.Query

  def get_customer(id) do
    Repo.get_by(User, id: id) |> Repo.preload([:profile, addresses: [:distance]])
  end

  def list_customers() do
    Repo.all(User) |> Repo.preload([:profile, addresses: [:distance]])
  end

  def get_customers(criteria) do
    query = from(u in User)

    Enum.reduce(criteria, query, fn
      {:paginate, %{page: page, per_page: per_page}}, query ->
        from q in query,
          offset: ^((page - 1) * per_page),
          limit: ^per_page

      {:sort, %{sort_by: sort_by, sort_order: sort_order}}, query ->
        from q in query,
          order_by: [{^sort_order, ^sort_by}]

      {:search_by, %{search_by: search_by, search_term: term}}, query ->
        search_pattern = "%#{term}%"
        IO.puts("Searching users")

        if search_by == "Email" do
          from q in query,
            where: ilike(q.email, ^search_pattern)
        else
          # TODO: Search by name
          query
        end
    end)
    |> Repo.all()
    |> Repo.preload([:profile, addresses: [:distance]])
  end
end
