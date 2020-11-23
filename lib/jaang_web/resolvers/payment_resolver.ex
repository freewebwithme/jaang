defmodule JaangWeb.Resolvers.PaymentResolver do
  alias Jaang.{AccountManager, StripeManager}

  @doc """
  Add payment method to Stripe customer and make it default payment method
  """
  def attach_payment_method(_, %{user_token: token, card_token: card_token}, _) do
    # Get user
    user = AccountManager.get_user_by_session_token(token)

    # if user has stripe id just attach payment method id to stripe account
    case is_nil(user.stripe_id) do
      # User has stripe id
      false ->
        with {:ok, payment_method_id} <- StripeManager.create_payment_method(card_token),
             {:ok, %{payment_method: payment_method}} <-
               StripeManager.create_setup_intent(user.stripe_id, payment_method_id),
             # Set as default payment source.
             :ok <- change_default_card(user.stripe_id, payment_method) do
          {:ok, %Stripe.List{data: cards}} = StripeManager.get_all_cards(user.stripe_id)

          # When I add a payment method to a customer
          # I set it as default uset is as default payment method
          credit_cards = build_credit_cards(cards, payment_method_id)

          {:ok, credit_cards}
        else
          {:error, message} ->
            {:error, message}
        end

      true ->
        # no stripe account so create new
        {:ok, stripe_id} = StripeManager.create_customer(user.email)

        # Add stripe id to user
        AccountManager.update_user(user, %{stripe_id: stripe_id})

        with {:ok, payment_method_id} <- StripeManager.create_payment_method(card_token),
             {:ok, %{payment_method: payment_method}} <-
               StripeManager.create_setup_intent(stripe_id, payment_method_id),
             # Set as default payment source
             :ok <- change_default_card(stripe_id, payment_method) do
          {:ok, %Stripe.List{data: cards}} = StripeManager.get_all_cards(stripe_id)

          # When I add a payment method to a customer
          # I set it as default uset is as default payment method
          credit_cards = build_credit_cards(cards, payment_method_id)

          {:ok, credit_cards}
        else
          {:error, message} ->
            {:error, message}
        end
    end
  end

  def change_payment_method(_, %{user_token: token, payment_method_id: payment_method_id}, _) do
    user = AccountManager.get_user_by_session_token(token)

    case change_default_card(user.stripe_id, payment_method_id) do
      :ok ->
        {:ok, %Stripe.List{data: cards}} = StripeManager.get_all_cards(user.stripe_id)
        credit_cards = build_credit_cards(cards, payment_method_id)
        {:ok, credit_cards}

      :error ->
        {:error, "Can't change payment method"}
    end
  end

  def delete_payment_method(_, %{user_token: token, payment_method_id: payment_method_id}, _) do
    case StripeManager.delete_payment_method(payment_method_id) do
      {:ok, _payment_method} ->
        user = AccountManager.get_user_by_session_token(token)
        # Get default credit card info from stripe
        {:ok, default_payment_method_id} = get_default_card(user.stripe_id)

        # Get all card information
        {:ok, %Stripe.List{data: cards}} = StripeManager.get_all_cards(user.stripe_id)
        credit_cards = build_credit_cards(cards, default_payment_method_id)
        {:ok, credit_cards}

      {:error, _} ->
        {:error, "Can't delete payment method"}
    end
  end

  def get_all_cards(_, %{user_token: token}, _) do
    user = AccountManager.get_user_by_session_token(token)

    case is_nil(user.stripe_id) do
      false ->
        # get default payment method from stripe customer
        {:ok, %{invoice_settings: %{default_payment_method: default_payment_method}}} =
          StripeManager.retrieve_customer(user.stripe_id)

        {:ok, %Stripe.List{data: cards}} = StripeManager.get_all_cards(user.stripe_id)

        credit_cards = build_credit_cards(cards, default_payment_method)

        {:ok, credit_cards}

      true ->
        # if there is no stripe id in account just return empty list
        # I don't want to create a stripe customer when a user navigate to
        # credit card screen.

        {:ok, []}
    end
  end

  defp build_credit_cards(cards, default_payment_method) do
    Enum.map(cards, fn %{
                         card: %{
                           brand: brand,
                           exp_month: exp_month,
                           exp_year: exp_year,
                           last4: last_four
                         },
                         id: payment_method_id
                       } ->
      %{
        brand: brand,
        exp_month: exp_month,
        exp_year: exp_year,
        last_four: last_four,
        payment_method_id: payment_method_id,
        default_card: default_payment_method == payment_method_id
      }
    end)
  end

  defp change_default_card(stripe_id, payment_method_id) do
    case StripeManager.update_customer(stripe_id, %{
           invoice_settings: %{default_payment_method: payment_method_id}
         }) do
      {:ok, _} -> :ok
      {:error, _} -> :error
    end
  end

  defp get_default_card(stripe_id) do
    case StripeManager.retrieve_customer(stripe_id) do
      {:ok, customer} ->
        %{invoice_settings: %{default_payment_method: payment_method_id}} = customer
        {:ok, payment_method_id}

      {:error, _error} ->
        {:error, nil}
    end
  end
end
