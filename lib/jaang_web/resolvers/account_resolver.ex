defmodule JaangWeb.Resolvers.AccountResolver do
  alias Jaang.Account.UserAuthMobile
  alias Jaang.AccountManager

  def log_in(_, %{email: email, password: password}, _) do
    case UserAuthMobile.log_in_mobile_user(email, password) do
      {:ok, user, token} ->
        {:ok, %{user: user, token: token}}

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
        {:ok, %{user: user, token: token}}

      _ ->
        {:error, "Can't register, please try again"}
    end
  end
end
