defmodule Jaang.Product.ProductPrice do
  @moduledoc """
  Product price that displayed in Client side(Retail price)
  depends on wholesale price.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Product.ProductPrice
  alias Jaang.Repo
  import Ecto.Query

  schema "product_prices" do
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime
    field :discount_percentage, :string
    field :on_sale, :boolean
    field :original_price, Money.Ecto.Amount.Type
    field :sale_price, Money.Ecto.Amount.Type

    belongs_to :product, Jaang.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%ProductPrice{} = product_price, attrs) do
    product_price
    |> cast(attrs, [
      :start_date,
      :end_date,
      :discount_percentage,
      :on_sale,
      :original_price,
      :sale_price,
      :product_id
    ])
  end

  def create_product_price(product_id, attrs) do
    %ProductPrice{}
    |> changeset(attrs)
    |> put_change(:product_id, product_id)
    |> Repo.insert()
  end

  def update_product_price(%ProductPrice{} = product_price, attrs) do
    product_price
    |> changeset(attrs)
    |> Repo.update!()
  end

  def delete_product_price(%ProductPrice{} = product_price) do
    product_price |> Repo.delete()
  end

  def list_product_price(product_id) do
    Repo.all(from pp in ProductPrice, where: pp.product_id == ^product_id)
  end

  @doc """
  Return not on sale, regular price
  """
  def get_product_price(product_id) do
    query =
      from pp in ProductPrice,
        where:
          pp.product_id == ^product_id and
            fragment("now() between ? and ?", pp.start_date, pp.end_date)

    Repo.one(query)
  end
end
