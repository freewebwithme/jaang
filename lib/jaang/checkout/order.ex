defmodule Jaang.Checkout.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Checkout.{Order, LineItem}

  schema "orders" do
    field :status, Ecto.Enum, values: [:cart, :confirmd]
    field :total, Money.Ecto.Amount.Type
    embeds_many :line_items, LineItem, on_replace: :delete

    field :store_id, :id

    belongs_to :user, Jaang.Account.User

    timestamps()
  end

  @doc false
  def changeset(%Order{} = order, attrs) do
    order
    |> cast(attrs, [:status, :total, :user_id, :store_id])
    |> cast_embed(:line_items, required: true, with: &LineItem.changeset/2)
    |> set_order_total()
    |> validate_required([:status, :total, :user_id])
  end

  defp set_order_total(changeset) do
    items = get_field(changeset, :line_items)

    total =
      Enum.reduce(items, Money.new(0), fn item, acc ->
        Money.add(acc, item.total)
      end)

    changeset
    |> put_change(:total, total)
  end
end
