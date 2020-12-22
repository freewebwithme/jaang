defmodule Jaang.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string

    has_many :products, Jaang.Product
    has_many :sub_categories, Jaang.Category.SubCategory

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Jaang.Category{} = category, attrs) do
    category
    |> cast(attrs, [:name])
  end
end
