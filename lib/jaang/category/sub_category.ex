defmodule Jaang.Category.SubCategory do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Subcategory module
  """

  schema "sub_categories" do
    field :name, :string

    belongs_to :category, Jaang.Category
    has_many :products, Jaang.Product
  end

  @doc false
  def changeset(%Jaang.Category.SubCategory{} = sub_category, attrs) do
    sub_category
    |> cast(attrs, [:name, :category_id])
    |> validate_length(:name, min: 3, max: 50)
    |> validate_required([:name, :category_id])

    #    |> foreign_key_constraint(:category)
  end
end
