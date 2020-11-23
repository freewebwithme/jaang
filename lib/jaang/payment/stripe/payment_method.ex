defmodule Jaang.Payment.Stripe.PaymentMethod do
  alias Stripe.PaymentMethod

  def get_all_cards(stripe_id) do
    PaymentMethod.list(%{customer: stripe_id, type: "card"})
  end

  def create_payment_method(card_token) do
    case PaymentMethod.create(%{"type" => "card", "card[token]" => card_token}) do
      {:ok, %{id: payment_method_id}} -> {:ok, payment_method_id}
      {:error, message} -> {:error, message}
    end
  end

  def attach_to_customer(payment_method_id, stripe_id) do
    case PaymentMethod.attach(%{customer: stripe_id, payment_method: payment_method_id}) do
      {:ok, _} -> {:ok, "success"}
      {:error, _} -> {:error, "error"}
    end
  end

  def retrieve_payment_method(payment_method_id) do
    case PaymentMethod.retrieve(payment_method_id) do
      {:ok, result} ->
        {:ok, result}

      {:error, _result} ->
        :error
    end
  end

  def delete_payment_method(payment_method_id) do
    case PaymentMethod.detach(%{payment_method: payment_method_id}, []) do
      {:ok, payment_method} -> {:ok, payment_method}
      {:error, error} -> {:error, error}
    end
  end
end
