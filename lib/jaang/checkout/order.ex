defmodule Jaang.Checkout.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Checkout.{Order, LineItem}

  schema "orders" do
    field :status, Ecto.Enum, values: [:cart, :confirmd]
    field :total, Money.Ecto.Amount.Type
    embeds_many :line_items, LineItem, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(%Order{} = order, attrs) do
    order
    |> cast(attrs, [:status, :total])
    |> cast_embed(:line_items)
    |> validate_required([:status, :total, :line_items])
  end
end
