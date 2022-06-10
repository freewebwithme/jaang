defmodule Jaang.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :description, :string

    has_many :products, Jaang.Product
    has_many :sub_categories, Jaang.Category.SubCategory

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Jaang.Category{} = category, attrs) do
    category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> validate_length(:name, min: 3, max: 50)
    |> validate_length(:description, min: 5, max: 200)
    |> cast_assoc(:sub_categories)
    |> no_assoc_constraint(:sub_categories)
  end
end
