defmodule Jaang.Invoice.ReceiptPhoto do
  use Ecto.Schema

  import Ecto.Changeset

  @derive Jason.Encoder
  embedded_schema do
    field :photo_url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = receipt_photo, attrs) do
    receipt_photo
    |> cast(attrs, [:photo_url])
  end
end
