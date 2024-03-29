defmodule JaangWeb.AuthController do
  use JaangWeb, :controller
  plug Ueberauth

  alias Jaang.AccountManager
  alias JaangWeb.UserAuth
  alias Ueberauth.Strategy.Helpers

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out")
    |> UserAuth.log_out_user()
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  @doc """
  Google OAuth Login
  """
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    %{info: %{email: email, first_name: first_name, last_name: last_name}} = auth
    attrs = %{email: email, profile: %{first_name: first_name, last_name: last_name}}

    # Check if user already has an account with us
    if user = AccountManager.get_user_by_email(email) do
      UserAuth.log_in_user(conn, user, %{})
    else
      case AccountManager.create_user_with_profile_using_google(attrs) do
        {:ok, user} ->
          UserAuth.log_in_user(conn, user, %{})

        {:error, changeset} ->
          render(conn, "request.html",
            error_message: "Invalid email or password",
            changeset: changeset,
            callback_url: Helpers.callback_url(conn)
          )
      end
    end
  end

  @doc """
  Regular log in using email and password
  """
  def identity_callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    %{
      extra: %{
        raw_info: %{"email" => email, "password" => password, "remember_me" => remember_me}
      }
    } = auth

    if user = AccountManager.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, %{"remember_me" => remember_me})
    else
      render(conn, "request.html",
        error_message: "Invalid email or password",
        callback_url: Helpers.callback_url(conn)
      )
    end
  end
end
