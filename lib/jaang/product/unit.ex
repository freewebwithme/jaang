defmodule Jaang.Product.Unit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "units" do
    field :name, :string

    belongs_to :product, Jaang.Product
  end

  @doc false
  def changeset(%Jaang.Product.Unit{} = unit, attrs) do
    unit
    |> cast(attrs, [:name, :product_id])
  end
end
