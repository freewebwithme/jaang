defmodule Jaang.Checkout.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Checkout.{Order, LineItem}

  @doc """
  This is for channel
  """
  @derive {Jason.Encoder,
           only: [
             :status,
             :total,
             :line_items,
             :store_id,
             :store_name,
             :store_logo,
             :user_id,
             :available_checkout,
             :required_amount
           ]}
  defprotocol MoneyProtocol do
    Protocol.derive(Jason.Encoder, Money)
  end

  schema "orders" do
    field :status, Ecto.Enum, values: [:cart, :submitted]
    field :total, Money.Ecto.Amount.Type
    embeds_many :line_items, LineItem, on_replace: :delete

    field :store_id, :id
    field :store_name, :string
    field :store_logo, :string
    field :invoice_id, :id
    field :available_checkout, :boolean, default: false
    # Minimum acount must be over $35
    field :required_amount, Money.Ecto.Amount.Type
    belongs_to :user, Jaang.Account.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Order{} = order, attrs) do
    order
    |> cast(attrs, [
      :status,
      :total,
      :user_id,
      :store_id,
      :store_name,
      :store_logo,
      :invoice_id,
      :available_checkout,
      :required_amount
    ])
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

    available_checkout = checkout_available(total)

    required_amount =
      cond do
        available_checkout == true ->
          Money.new(0, :USD)

        available_checkout == false ->
          calculate_require_amount(total)
      end

    changeset
    |> put_change(:total, total)
    |> put_change(:available_checkout, available_checkout)
    |> put_change(:required_amount, required_amount)
  end

  # Calculate if total price is over $35
  # and update :avilable_checkout in order
  # param: %Money{0, :USD}
  defp checkout_available(total) do
    if(Money.compare(total, Money.new(3500, :USD)) >= 0) do
      true
    else
      false
    end
  end

  # Minimum total must be over $35
  defp calculate_require_amount(total) do
    Money.subtract(Money.new(3500, :USD), total)
  end
end
