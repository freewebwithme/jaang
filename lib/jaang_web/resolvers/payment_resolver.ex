defmodule JaangWeb.Resolvers.PaymentResolver do
  alias Jaang.{AccountManager, StripeManager}

  def attach_payment_method(_, %{user_token: token, payment_method_id: payment_method_id}, _) do
    # Get user
    user = AccountManager.get_user_by_session_token(token)

    # if user has stripe id just attach payment method id to stripe account
    case is_nil(user.stripe_id) do
      false ->
        # attach payment method id to stripe user using SetupIntent
        StripeManager.create_setup_intent(user.stripe_id, payment_method_id)
        {:ok, %Stripe.List{data: cards}} = StripeManager.get_all_cards(user.stripe_id)

        {:ok, build_credit_cards(cards)}

      true ->
        # no stripe account create it
        {:ok, stripe_id} = StripeManager.create_customer(user.email)

        # Add stripe id to user
        AccountManager.update_user(user, %{stripe_id: stripe_id})

        StripeManager.create_setup_intent(stripe_id, payment_method_id)
        {:ok, %Stripe.List{data: cards}} = StripeManager.get_all_cards(stripe_id)

        {:ok, build_credit_cards(cards)}
    end
  end

  def get_all_cards(_, %{user_token: token}, _) do
    user = AccountManager.get_user_by_session_token(token)

    case is_nil(user.stripe_id) do
      false ->
        {:ok, %Stripe.List{data: cards}} = StripeManager.get_all_cards(user.stripe_id)

        credit_cards = build_credit_cards(cards)

        {:ok, credit_cards}

      true ->
        # if there is no stripe id in account just return empty list
        # I don't want to create a stripe customer when a user navigate to
        # credit card screen.

        {:ok, []}
    end
  end

  defp build_credit_cards(cards) do
    Enum.map(cards, fn %{
                         card: %{
                           brand: brand,
                           exp_month: exp_month,
                           exp_year: exp_year,
                           last4: last_four
                         }
                       } ->
      %{brand: brand, exp_month: exp_month, exp_year: exp_year, last_four: last_four}
    end)
  end
end
