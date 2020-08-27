defmodule JaangWeb.AccountConfirmationControllerTest do
  use JaangWeb.ConnCase
  alias Jaang.AccountManager
  alias Jaang.Account.UserToken

  test "render account confirmation page", %{conn: conn} do
    conn = get(conn, Routes.account_confirmation_path(conn, :new))
    assert html_response(conn, 200) =~ "Resend confirmation instructions"
  end

  test "create method redirect to home page", %{conn: conn} do
    conn =
      post(conn, Routes.account_confirmation_path(conn, :create),
        user: %{"email" => "taedori@example.com"}
      )

    assert redirected_to(conn) =~ "/"
  end

  test "failed to confirm", %{conn: conn} do
    conn = get(conn, Routes.account_confirmation_path(conn, :confirm, "wrong token"))

    assert get_flash(conn, :error) == "Confirmation link is invalid or it has expired"
  end

  test "succeed to confirm", %{conn: conn} do
    # create user
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

    # create confirmation link
    {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
    Jaang.Repo.insert!(user_token)

    conn = get(conn, Routes.account_confirmation_path(conn, :confirm, encoded_token))

    assert get_flash(conn, :info) == "Account confirmed successfully."
    assert redirected_to(conn) == "/"
  end
end
