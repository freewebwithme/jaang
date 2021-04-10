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
             :order_placed_at,
             :required_amount
           ]}

  defprotocol MoneyProtocol do
    Protocol.derive(Jason.Encoder, Money)
  end

  schema "orders" do
    field :status, Ecto.Enum,
      values: [:cart, :refunded, :submitted, :shopping, :packed, :on_the_way, :delivered]

    field :total, Money.Ecto.Amount.Type
    embeds_many :line_items, LineItem, on_replace: :delete

    field :store_id, :id
    field :store_name, :string
    field :store_logo, :string
    field :invoice_id, :id
    field :available_checkout, :boolean, default: false
    field :order_placed_at, :utc_datetime
    # Minimum acount must be over $35
    field :required_amount, Money.Ecto.Amount.Type
    belongs_to :user, Jaang.Account.User

    many_to_many :employees, Jaang.Admin.Account.Employee.Employee,
      join_through: Jaang.Admin.Account.Employee.EmployeeAssignedOrder

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
      :required_amount,
      :order_placed_at
    ])
    |> cast_embed(:line_items, required: true, with: &LineItem.changeset/2)
    |> set_order_total()
    |> set_checkout_available()
    |> validate_required([:status, :total, :user_id])
  end

  @doc """
  Assign employees to order and change status(:shopping, :on_the_way)
  """
  def assign_employee_changeset(%Order{} = order, employee, status) do
    order
    |> change(%{status: status})
    |> put_assoc(:employees, [employee | order.employees])
  end

  def set_order_total(changeset) do
    items = get_field(changeset, :line_items)

    total =
      Enum.reduce(items, Money.new(0), fn item, acc ->
        Money.add(acc, item.total)
      end)

    changeset
    |> put_change(:total, total)
  end

  def set_checkout_available(changeset) do
    total = get_field(changeset, :total)

    available_checkout = checkout_available?(total)

    required_amount =
      case available_checkout do
        true ->
          Money.new(0, :USD)

        _ ->
          calculate_require_amount(total)
      end

    changeset
    |> put_change(:available_checkout, available_checkout)
    |> put_change(:required_amount, required_amount)
  end

  # Calculate if total price is over $35
  # and update :avilable_checkout in order
  # param: %Money{0, :USD}
  defp checkout_available?(total) do
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
