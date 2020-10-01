defmodule Jaang.Account.UserAuthMobile do
  @moduledoc """
  User authentication moduel for Graphql API
  """
  alias Jaang.AccountManager
  alias Jaang.Repo
  import Ecto.Query

  @doc """
  Log in a user using email and password
  If success, save UserToken schema to database.
  and return user schema and token
  """
  def log_in_mobile_user(email, password) do
    if user = AccountManager.get_user_by_email_and_password(email, password) do
      token = generate_user_session_token(user)
      {:ok, user, token}
    else
      {:error, "Can't log in"}
    end
  end

  def generate_user_session_token(user) do
    IO.inspect(user)
    {token, user_token} = build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @salt "jaang mobile token"
  def build_session_token(user) do
    token = Phoenix.Token.sign(JaangWeb.Endpoint, @salt, %{id: user.id})
    {token, %Jaang.Account.UserToken{token: token, context: "session", user_id: user.id}}
  end

  def delete_session_token(token) do
    user_token = token_and_context_query(token, "session") |> Repo.one()

    if user_token do
      case Repo.delete(user_token) do
        {:ok, struct} -> {:ok, struct}
        {:error, changeset} -> {:error, changeset}
      end
    end
  end

  @session_validity_in_days 60
  # 60 days
  @max_age 24 * 60 * 60 * 60

  def verify_session_token_query(token) do
    case Phoenix.Token.verify(JaangWeb.Endpoint, @salt, token, max_age: @max_age) do
      {:ok, _user_id} ->
        query =
          from token in token_and_context_query(token, "session"),
            join: user in assoc(token, :user),
            where: token.inserted_at > ago(@session_validity_in_days, "day"),
            select: user

        {:ok, query}

      {:error, _} ->
        nil
    end
  end

  def get_user_by_session_token(token) do
    with {:ok, query} <- verify_session_token_query(token),
         %{} = user <- Repo.one(query) |> Repo.preload(:profile) do
      {:ok, user}
    else
      nil -> {:error, "Can't find a user"}
    end
  end

  def token_and_context_query(token, context) do
    from Jaang.Account.UserToken, where: [token: ^token, context: ^context]
  end
end
