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

      {:error, error} ->
        IO.puts("Inspecting create customer error message")
        IO.inspect(error)
        {:error, error}
    end
  end

  @doc """
  Update Stripe customer information
  """
  def update_customer(stripe_id, attrs) do
    case(Customer.update(stripe_id, attrs)) do
      {:ok, result} -> {:ok, result}
      {:error, result} -> {:error, result}
    end
  end

  @doc """
  Retrieve a customer
  """
  def retrieve_customer(stripe_id) do
    Customer.retrieve(stripe_id)
  end
end
