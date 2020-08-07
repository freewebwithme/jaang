defmodule Jaang.Store do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stores" do
    field :name, :string

    has_many :products, Jaang.Product
  end
end
