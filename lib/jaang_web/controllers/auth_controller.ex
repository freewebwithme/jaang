defmodule JaangWeb.AuthController do
  use JaangWeb, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out")
    |> clear_session()
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  # TODO: Implement fail scenario
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    IO.puts("printing ueberauth auth struct")
    IO.inspect(auth)

    conn
    |> put_flash(:info, "Successfully logged in")
    |> put_session(:current_user, "user")
    |> configure_session(renew: true)
    |> redirect(to: "/")
  end

  def identity_callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    IO.puts("printing ueberauth identity auth struct")
    IO.inspect(auth)

    conn
    |> put_flash(:info, "Successfully logged in")
    |> put_session(:current_user, "user")
    |> configure_session(renew: true)
    |> redirect(to: "/")
  end
end
