defmodule JaangWeb.AuthControllerTest do
  use JaangWeb.ConnCase
  alias Ueberauth.Strategy.Helpers
  alias Jaang.AccountManager

  @create_user %{
    email: "taedori@example.com",
    password: "secretsecret",
    password_confirmation: "secretsecret",
    profile: %{
      first_name: "James",
      last_name: "Doe"
    }
  }

  @ueberauth_assigns %{
    extra: %{
      raw_info: %{
        "email" => "taedori@example.com",
        "password" => "secretsecret",
        "remember_me" => "false"
      }
    }
  }

  setup do
    {:ok, user} = AccountManager.create_user_with_profile(@create_user)
    {:ok, %{user: user}}
  end

  describe "login page" do
    test "login page has callback_url for normal login", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :request, "identity"))
      callback_url = Helpers.callback_url(conn)
      assert callback_url == conn.assigns.callback_url
    end

    test "login page loading correctly", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :request, "identity"))
      assert html_response(conn, 200) =~ "Log in to your account"
    end
  end

  test "identity callback logs in user", %{conn: conn} do
    conn = assign(conn, :ueberauth_auth, @ueberauth_assigns)
    conn = post(conn, Routes.auth_path(conn, :identity_callback))
    assert redirected_to(conn) =~ "/store"
  end

  test "delete function log the user out correctly", %{conn: conn} do
    conn = delete(conn, Routes.auth_path(conn, :delete))
    assert redirected_to(conn) =~ "/"
  end
end
