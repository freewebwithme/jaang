defmodule Jaang.Payment.Stripe.PaymentIntent do
  alias Stripe.PaymentIntent

  @doc """
  Used for place a payment on hold
  returns payment intent struct
  """
  def create_payment_intent(amount, stripe_id, payment_method) do
    PaymentIntent.create(%{
      customer: stripe_id,
      payment_method: payment_method,
      # don't ask user to confirm, when user click place an order, that is confirmed
      confirm: true,
      amount: amount,
      currency: "USD",
      # Capture later.
      capture_method: "manual"
    })
  end

  @doc """
  Finally capture the payment
  params: payment_intent_id, amount to capture
  """
  def capture_payment_intent(payment_intent_id, amount_to_capture) do
    PaymentIntent.capture(payment_intent_id, %{amount_to_capture: amount_to_capture})
  end
end
