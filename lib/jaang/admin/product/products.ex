defmodule Jaang.Admin.Product.Products do
  alias Jaang.Product
  import Ecto.Query
  alias Jaang.Repo

  @doc """
  Returns a list of invoice matching the given `criteria`

  Example Criteria:

  [
   paginate: %{page: 2, per_page: 5},
   sort: %{sort_by: :delivery_time, sort_order: :asc}
   filter_by: %{by_state: :submitted}
  ]
  """
  def get_products(store_id, criteria) when is_list(criteria) do
    query = from(p in Product, where: p.store_id == ^store_id)
    IO.puts("getting products")

    products =
      Enum.reduce(criteria, query, fn
        {:paginate, %{page: page, per_page: per_page}}, query ->
          from q in query,
            offset: ^((page - 1) * per_page),
            limit: ^per_page

        {:sort, %{sort_by: sort_by, sort_order: sort_order}}, query ->
          from q in query,
            order_by: [{^sort_order, ^sort_by}]

        {:filter_by, %{by_state: state}}, query ->
          cond do
            state == "Published" ->
              from(q in query, where: q.published == true)

            state == "Unpublished" ->
              from(q in query, where: q.published == false)

            state == "All" ->
              from(q in query)

            true ->
              from(q in query)
          end

        {:search_by, %{search_by: search_by, search_term: term}}, query ->
          search_pattern = "%#{term}%"
          IO.puts("searching products")

          if search_by == "Name" do
            IO.puts("Search by name")

            from q in query,
              where: ilike(q.name, ^search_pattern)
          else
            from q in query,
              where: ilike(q.barcode, ^search_pattern)
          end
      end)
      |> Repo.all()
      |> Repo.preload([:market_prices, :product_prices, :product_images])

    products
  end

  def get_product(store_id, product_id) do
    # query = from p in Product, where: p.store_id == ^store_id, where: p.id == ^product_id
    query =
      from p in Product,
        where: p.store_id == ^store_id,
        where: p.id == ^product_id,
        join: mp in assoc(p, :market_prices),
        on: mp.product_id == p.id,
        where: fragment("now() between ? and ?", mp.start_date, mp.end_date),
        join: pp in assoc(p, :product_prices),
        on: pp.product_id == p.id,
        where: fragment("now() between ? and ?", mp.start_date, pp.end_date),
        preload: [market_prices: mp, product_prices: pp]

    Repo.one(query)
    |> Repo.preload([
      :product_images,
      :tags,
      :recipe_tags,
      :category,
      :sub_category
    ])
  end

  @doc """
  Get all products depends on published state and by Store id
  params: published = true or false
          store_id = 1
  """
  def get_products_by_published_state(published, store_id) do
    query = from p in Product, where: p.published == ^published and p.store_id == ^store_id
    Repo.all(query)
  end

  def list_products_by_store(store_id) do
    query = from p in Product, where: p.store_id == ^store_id
    Repo.all(query) |> Repo.preload([:market_prices, :product_prices, :product_images])
  end
end
