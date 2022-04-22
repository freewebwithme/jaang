defmodule Jaang.Checkout.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Checkout.{Order, LineItem}
  alias Jaang.Invoice.ReceiptPhoto

  @doc """
  This is for channel
  """
  @derive {Jason.Encoder,
           only: [
             :id,
             :status,
             :total,
             :line_items,
             :store_id,
             :store_name,
             :store_logo,
             :user_id,
             :available_checkout,
             :order_placed_at,
             :required_amount,
             :delivery_time,
             :delivery_date,
             :delivery_order,
             :delivery_fee,
             :delivery_tip,
             :sales_tax,
             :item_adjustment,
             :total_items,
             :number_of_bags,
             :instruction,
             :recipient,
             :address_line_one,
             :address_line_two,
             :business_name,
             :zipcode,
             :city,
             :state,
             :phone_number,
             :delivery_method,
             :receipt_photos,
             :grand_total,
             :grand_total_after_refund,
             :finalized
           ]}

  # defprotocol MoneyProtocol do
  #  Protocol.derive(Jason.Encoder, Money)
  # end

  schema "orders" do
    field :status, Ecto.Enum,
      values: [
        :cart,
        :refunded,
        :partially_refunded,
        :submitted,
        :shopping,
        :packed,
        :on_the_way,
        :delivered
      ]

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

    # New fields
    field :delivery_time, :string
    field :delivery_date, :date
    field :delivery_order, :integer
    field :delivery_fee, Money.Ecto.Amount.Type
    field :delivery_tip, Money.Ecto.Amount.Type
    field :sales_tax, Money.Ecto.Amount.Type
    field :item_adjustment, Money.Ecto.Amount.Type
    field :total_items, :integer
    field :grand_total, Money.Ecto.Amount.Type

    # if orders' status in [:refunded, :partially_refunded]
    field :grand_total_after_refund, Money.Ecto.Amount.Type
    field :number_of_bags, :integer, default: 0
    field :instruction, :string

    field :recipient, :string
    field :address_line_one, :string
    field :address_line_two, :string
    field :business_name, :string
    field :zipcode, :string
    field :city, :string
    field :state, :string

    # if worker finalize order, then true
    field :finalized, :boolean

    field :phone_number, :string

    # ex) hand over to customer, leave at the front door
    field :delivery_method, :string

    has_one :refund_request, Jaang.Admin.CustomerService.RefundRequest

    embeds_many :receipt_photos, Jaang.Invoice.ReceiptPhoto, on_replace: :delete

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
      :order_placed_at,
      :delivery_time,
      :delivery_date,
      :delivery_order,
      :delivery_fee,
      :delivery_tip,
      :sales_tax,
      :item_adjustment,
      :total_items,
      :number_of_bags,
      :instruction,
      :recipient,
      :address_line_one,
      :address_line_two,
      :business_name,
      :zipcode,
      :city,
      :state,
      :phone_number,
      :delivery_method,
      :grand_total,
      :grand_total_after_refund,
      :finalized
    ])
    |> cast_embed(:receipt_photos, required: false, with: &ReceiptPhoto.changeset/2)
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

    # if line_item is replaced, get total from
    # replacement item
    total =
      Enum.reduce(items, Money.new(0), fn item, acc ->
        if item.replaced do
          Money.add(acc, item.replacement_item.total)
        else
          Money.add(acc, item.total)
        end
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
    if Money.compare(total, Money.new(3500, :USD)) >= 0 do
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
