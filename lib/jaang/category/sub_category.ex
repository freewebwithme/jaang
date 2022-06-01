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
  end
end
