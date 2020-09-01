defmodule Jaang.Account.UserAuth do
  @moduledoc """
  User authentication moduel for Graphql API
  """
  alias Jaang.AccountManager

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.

  @doc """
  Log in a user using email and password
  If success, save UserToken schema to database.
  and return user schema and token
  """
  def log_in_user(email, password) do
    if user = AccountManager.get_user_by_email_and_password(email, password) do
      token = AccountManager.generate_user_session_token(user)
      {user, token}
    else
      nil
    end
  end
end
