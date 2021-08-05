defmodule Jaang.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Invoice

  @derive {Jason.Encoder, except: [:__meta__, :employees]}
  schema "invoices" do
    field :invoice_number, :string
    field :total_items, :integer
    field :payment_method, :string
    field :pm_intent_id, :string
    field :status, :string

    field :invoice_placed_at, :utc_datetime
    field :grand_total_price, Money.Ecto.Amount.Type

    belongs_to :user, Jaang.Account.User
    has_many :orders, Jaang.Checkout.Order

    timestamps(type: :utc_datetime)
  end

  # Convert %Money{amount: 0, currency: :USD} to $0
  defimpl Jason.Encoder, for: Money do
    def encode(struct, opts) do
      Jason.Encode.string(Money.to_string(struct), opts)
    end
  end

  @doc false
  def changeset(%Invoice{} = invoice, attrs) do
    fields = [
      :payment_method,
      :user_id,
      :pm_intent_id,
      :invoice_number,
      :total_items,
      :invoice_placed_at,
      :grand_total_price,
      :status
    ]

    invoice
    |> cast(attrs, fields)
    |> validate_required([
      :user_id
    ])
  end
end
