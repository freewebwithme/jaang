defmodule JaangWeb.ResetPasswordControllerTest do
  use JaangWeb.ConnCase
  alias Jaang.AccountManager
  alias Jaang.Account.UserToken

  test "reset password page", %{conn: conn} do
    conn = get(conn, Routes.reset_password_path(conn, :new))
    assert html_response(conn, 200) =~ "Forgot password?"
  end

  test "reset password create method redirect", %{conn: conn} do
    conn =
      post(conn, Routes.reset_password_path(conn, :create),
        user: %{"email" => "taedori@example.com"}
      )

    assert redirected_to(conn) =~ "/"
  end

  test "reset password edit method fail with wrong token", %{conn: conn} do
    conn = get(conn, Routes.reset_password_path(conn, :edit, "wrong token"))
    assert get_flash(conn, :error) == "Reset password link is invalid or it has expired"
  end

  test "reset password update method success", %{conn: conn} do
    {:ok, user} =
      AccountManager.create_user_with_profile(%{
        email: "taedori@example.com",
        password: "secretsecret",
        password_confirmation: "secretsecret",
        profile: %{
          first_name: "John",
          last_name: "Doe"
        }
      })

    # create token
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Jaang.Repo.insert!(user_token)

    user_params = %{password: "secretsecret1", password_confirmation: "secretsecret1"}
    conn = put(conn, Routes.reset_password_path(conn, :update, encoded_token), user: user_params)

    assert redirected_to(conn) =~ Routes.auth_path(conn, :request, "identity")
    assert get_flash(conn, :info) == "Password reset successfully."
  end

  test "reset password edit method success with correct token", %{conn: conn} do
    # create a user
    {:ok, user} =
      AccountManager.create_user_with_profile(%{
        email: "taedori@example.com",
        password: "secretsecret",
        password_confirmation: "secretsecret",
        profile: %{
          first_name: "John",
          last_name: "Doe"
        }
      })

    # create token
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Jaang.Repo.insert!(user_token)
    url = Routes.reset_password_path(conn, :edit, encoded_token)

    conn = get(conn, url)

    assert html_response(conn, 200) =~ "Reset password"
  end
end
