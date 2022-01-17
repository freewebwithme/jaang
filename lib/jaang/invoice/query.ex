defmodule Jaang.Invoice.Query do
  import Ecto.Query
  alias Jaang.Invoice

  def base(), do: Invoice
end
