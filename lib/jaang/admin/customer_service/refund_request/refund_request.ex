defmodule Jaang.Admin.CustomerService.RefundRequest do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Checkout.LineItem

  schema "refund_requests" do
    field :status, Ecto.Enum, values: [:refunded, :denied, :not_completed]

    field :subtotal, Money.Ecto.Amount.Type
    field :sales_tax, Money.Ecto.Amount.Type
    field :total_requested_refund, Money.Ecto.Amount.Type
    field :total_accepted_refund, Money.Ecto.Amount.Type
    field :deny_reason, :string

    embeds_many :refund_items, LineItem, on_replace: :delete
    belongs_to :user, Jaang.Account.User
    belongs_to :order, Jaang.Checkout.Order

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = refund_request, attrs) do
    refund_request
    |> cast(attrs, [
      :status,
      :user_id,
      :order_id,
      :total_requested_refund,
      :subtotal,
      :sales_tax,
      :total_accepted_refund,
      :deny_reason
    ])
    |> validate_required([:refund_items])
    |> cast_embed(:refund_items, required: true, with: &LineItem.changeset_for_refund/2)
    |> calculate_subtotal_refund()
    |> calculate_sales_tax()
    |> calculate_total_refund()
  end

  @tax_rate 0.095
  def calculate_sales_tax(changeset) do
    refund_item_changesets = get_change(changeset, :refund_items)

    if refund_item_changesets != nil do
      total_sales_tax =
        Enum.reduce(refund_item_changesets, Money.new(0), fn refund_item_changeset, acc ->
          case get_change(refund_item_changeset, :replaced) do
            true ->
              replacement_item_changeset = get_change(refund_item_changeset, :replacement_item)
              category = get_change(replacement_item_changeset, :category_name)

              if category == "Produce" do
                Money.add(Money.new(0), acc)
              else
                total = get_change(replacement_item_changeset, :total)
                sales_tax = Money.multiply(total, @tax_rate)
                Money.add(sales_tax, acc)
              end

            _ ->
              category = get_change(refund_item_changeset, :category_name)

              if category == "Produce" do
                Money.add(Money.new(0), acc)
              else
                total = get_change(refund_item_changeset, :total)

                sales_tax = Money.multiply(total, @tax_rate)
                Money.add(sales_tax, acc)
              end
          end
        end)

      put_change(changeset, :sales_tax, total_sales_tax)
    else
      changeset
    end
  end

  def calculate_subtotal_refund(changeset) do
    refund_item_changesets = get_change(changeset, :refund_items)

    if refund_item_changesets != nil do
      subtotal =
        Enum.reduce(refund_item_changesets, Money.new(0), fn refund_item_changeset, acc ->
          case get_change(refund_item_changeset, :replaced) do
            true ->
              replacement_item_changeset = get_change(refund_item_changeset, :replacement_item)
              total = get_change(replacement_item_changeset, :total)
              Money.add(total, acc)

            _ ->
              total = get_change(refund_item_changeset, :total)
              Money.add(total, acc)
          end
        end)

      put_change(changeset, :subtotal, subtotal)
    else
      changeset
    end
  end

  def calculate_total_refund(changeset) do
    sales_tax = get_change(changeset, :sales_tax)
    subtotal = get_change(changeset, :subtotal)

    if sales_tax == nil || subtotal == nil do
      changeset
    else
      total = Money.add(sales_tax, subtotal)
      put_change(changeset, :total_requested_refund, total)
    end
  end
end
