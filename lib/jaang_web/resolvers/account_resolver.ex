defmodule JaangWeb.Resolvers.AccountResolver do
  alias Jaang.Account.UserAuthMobile
  alias Jaang.AccountManager

  def log_in(_, %{email: email, password: password}, _) do
    case UserAuthMobile.log_in_mobile_user(email, password) do
      {:ok, user, token} ->
        {:ok, %{user: user, token: token, expired: false}}

      _ ->
        {:error, "Can't log in"}
    end
  end

  def sign_up(_, args, _) do
    %{email: email, password: password} = args

    IO.inspect(args)

    case AccountManager.create_user_with_profile(args) do
      {:ok, user} ->
        Jaang.EmailManager.send_welcome_email(user)
        {:ok, user, token} = UserAuthMobile.log_in_mobile_user(email, password)
        {:ok, %{user: user, token: token, expired: false}}

      _ ->
        {:error, "Can't register, please try again"}
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

  @doc """
  Authenticate google user with idToken
  """
  def googleSignIn_with_id_token(_, %{idToken: idToken}, _) do
    case AccountManager.authenticate_google_idToken(idToken) do
      {:ok, user} ->
        # User signs in with google and authenticated
        # and generate session token
        token = AccountManager.generate_user_session_token(user)
        {:ok, %{user: user, token: token, expired: false}}

      _ ->
        {:error, "Something wrong, please try again"}
    end
  end

  @doc """
  Autheticate google user using email
  """
  def google_signIn(_, %{email: email, display_name: display_name}, _) do
    {:ok, user} = AccountManager.google_signin_from_mobile(email, display_name)
    token = UserAuthMobile.generate_user_session_token(user)
    {:ok, %{user: user, token: token, expired: false}}
  end

  @doc """
  Verify session token from client
  """
  def verify_token(_, %{token: token}, _) do
    case UserAuthMobile.get_user_by_session_token(token) do
      {:ok, user} ->
        {:ok, %{user: user, token: token, expired: false}}

      {:error, _} ->
        {:ok, %{user: nil, token: token, expired: true}}
    end
  end
end
