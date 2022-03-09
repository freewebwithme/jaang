defmodule JaangWeb.Resolvers.AccountResolver do
  alias Jaang.Account.UserAuthMobile
  alias Jaang.{AccountManager}
  require Logger

  def log_in(_, %{email: email, password: password}, _) do
    case UserAuthMobile.log_in_mobile_user(email, password) do
      {:ok, user, token} ->
        # get cart or create new
        # carts = OrderManager.get_all_carts_or_create_new(user)
        {:ok, %{user: user, token: token, expired: false}}

      _ ->
        {:error, "Can't log in"}
    end
  end

  def sign_up(_, args, _) do
    %{
      email: email,
      password: password,
      password_confirmation: password_confirmation,
      first_name: first_name,
      last_name: last_name
    } = args

    # Remap for profile
    attrs = %{
      email: email,
      password: password,
      password_confirmation: password_confirmation,
      profile: %{first_name: first_name, last_name: last_name}
    }

    case AccountManager.create_user_with_profile(attrs) do
      {:ok, user} ->
        Jaang.EmailManager.send_welcome_email(user)
        {:ok, user, token} = UserAuthMobile.log_in_mobile_user(email, password)

        # get cart or create new
        # carts = OrderManager.get_all_carts_or_create_new(user)

        {:ok, %{user: user, token: token, expired: false}}

      {:error, changeset} ->
        Logger.error("Customer sign up failed #{inspect(changeset)}")
        {:error, message: "Error occured from server"}
    end
  end

  def reset_password(_, %{email: email}, _) do
    if user = AccountManager.get_user_by_email(email) do
      AccountManager.deliver_user_reset_password_instructions(
        user,
        &JaangWeb.Router.Helpers.reset_password_url(JaangWeb.Endpoint, :edit, &1)
      )

      {:ok, %{sent: true, message: "email sent"}}
    else
      {:ok, %{sent: false, message: "email not sent"}}
    end
  end

  def resend_confirmation_email(_, %{user_token: token}, _) do
    user = AccountManager.get_user_by_session_token(token)

    if user.confirmed_at do
      {:ok, %{sent: false, message: "email not sent"}}
    else
      # Resend confirmation email
      AccountManager.deliver_user_confirmation_instructions(
        user,
        &JaangWeb.Router.Helpers.account_confirmation_url(JaangWeb.Endpoint, :confirm, &1)
      )

      {:ok, %{sent: true, message: "email sent"}}
    end
  end

  @doc """
  Autheticate google user using email
  """
  def google_signIn(_, %{email: email, display_name: display_name, photo_url: photo_url}, _) do
    {:ok, user} = AccountManager.google_signin_from_mobile(email, display_name, photo_url)
    token = UserAuthMobile.generate_user_session_token(user)

    {:ok, %{user: user, token: token, expired: false}}
  end

  @doc """
  Authenticate user using Google idToken
  """
  def google_signIn_with_id_token(_, %{id_token: id_token}, _) do

    case AccountManager.authenticate_google_idToken(id_token) do
	    {:ok, user} ->
        token = UserAuthMobile.generate_user_session_token(user)

        {:ok, %{user: user, token: token, expired: false}}

      {:error, message} ->
        IO.puts("idToken error")
        IO.inspect(message)
        {:error, message}
    end
  end

  @doc """
  Verify session token from client
  """
  def verify_token(_, %{token: token}, _) do
    case UserAuthMobile.get_user_by_session_token(token) do
      {:ok, user} ->
        # get cart or create new
        # carts = OrderManager.get_all_carts_or_create_new(user)

        {:ok, %{user: user, token: token, expired: false}}

      {:error, _} ->
        {:ok, %{user: nil, token: token, expired: true}}
    end
  end

  @doc """
  Log a user out
  Delete session token from database and return empty session
  """
  def log_out(_, %{token: token}, _) do
    case UserAuthMobile.delete_session_token(token) do
      {:ok, _struct} ->
        {:ok, %{user: nil, token: nil, expired: true}}

      {:error, _changeset} ->
        {:error, "Can't delete session token"}
    end
  end
end
