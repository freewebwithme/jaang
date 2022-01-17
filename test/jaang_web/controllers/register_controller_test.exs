defmodule JaangWeb.RegisterControllerTest do
  use JaangWeb.ConnCase

  test "render register page correctly", %{conn: conn} do
    conn = get(conn, Routes.register_path(conn, :index))
    assert html_response(conn, 200) =~ "Register your account"
  end

  test "register page has changeset", %{conn: conn} do
    conn = get(conn, Routes.register_path(conn, :index))
    refute is_nil(conn.assigns.changeset)
  end

  @user_params %{
    email: "taedori@example.com",
    password: "secretsecret",
    password_confirmation: "secretsecret",
    profile: %{
      first_name: "John",
      last_name: "Doe"
    }
  }

  test "registering with wrong recaptcha", %{conn: conn} do
    conn =
      post(conn, Routes.register_path(conn, :create), %{
        "g-recaptcha-response" => "wrong value",
        "user" => @user_params
      })

    assert redirected_to(conn) =~ Routes.register_path(conn, :index)
  end
end
