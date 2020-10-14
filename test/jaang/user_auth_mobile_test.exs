defmodule Jaang.UserAuthMobileTest do
  use Jaang.DataCase, async: true

  alias Jaang.Account.UserAuthMobile
  alias Jaang.AccountManager
  alias Jaang.Account.User

  @session_validity_in_days 60
  # 60 days
  @max_age 24 * 60 * 60 * 60

  setup do
    # Create an user

    attrs = %{
      email: "test@example.com",
      password: "secretsecret",
      password_confirmation: "secretsecret",
      profile: %{
        first_name: "Taehwan",
        last_name: "Kim",
        phone: "2135055819"
      }
    }

    {:ok, user} = AccountManager.create_user_with_profile(attrs)

    {:ok, %{user: user}}
  end

  test "generate_user_session_token", context do
    user = context[:user]
    token = UserAuthMobile.generate_user_session_token(user)

    assert {:ok, %{id: user_id}} =
             Phoenix.Token.verify(JaangWeb.Endpoint, "jaang mobile token", token,
               max_age: @max_age
             )

    assert user_id == user.id
  end

  test "verify_session_token_query", context do
    user = context[:user]
    token = UserAuthMobile.generate_user_session_token(user)

    assert {:ok, query} = UserAuthMobile.verify_session_token_query(token)

    saved_user = Jaang.Repo.one(query)
    assert user.id == saved_user.id
  end

  test "get_user_by_session_token", context do
    user = context[:user]
    token = UserAuthMobile.generate_user_session_token(user)

    {:ok, saved_user} = UserAuthMobile.get_user_by_session_token(token)
    assert user.id == saved_user.id
    refute user.id == 9999
  end
end
