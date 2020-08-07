defmodule Jaang.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string

    has_many :products, Jaang.Product
  end
end
