defmodule Jaang.Product.Unit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "units" do
    # lb, each, pack, bundle
    field :name, :string
    # has_many :products, Jaang.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Jaang.Product.Unit{} = unit, attrs) do
    unit
    |> cast(attrs, [:name])
    |> unique_constraint(:name)
  end
end
