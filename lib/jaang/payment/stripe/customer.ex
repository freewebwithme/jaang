defmodule Jaang.Payment.Stripe.Customer do
  alias Stripe.{Customer}

  @doc """
  Create stripe customer using user's email
  and return stripe id.
  """
  def create_customer(email) do
    case Customer.create(%{email: email}) do
      {:ok, %{id: stripe_id}} ->
        # Save stripe id
        {:ok, stripe_id}

      {:error, _stripe} ->
        {:error, "Can't create a stripe account"}
    end
  end
end
