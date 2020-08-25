defmodule JaangWeb.ResetPasswordController do
  use JaangWeb, :controller
  alias Jaang.AccountManager

  plug :get_user_by_reset_password_token when action in [:edit, :update]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"email" => email}}) do
    if user = AccountManager.get_user_by_email(email) do
      AccountManager.deliver_user_reset_password_instructions(
        user,
        &Routes.reset_password_url(conn, :edit, &1)
      )
    end

    conn
    |> put_flash(
      :info,
      "If your e-mail is in our system, you will receive instructions to reset your password shortly"
    )
    |> redirect(to: "/")
  end

  def edit(conn, _params) do
    render(conn, "edit.html", changeset: AccountManager.change_user_password(conn.assigns.user))
  end

  def update(conn, %{"user" => user_params}) do
    case AccountManager.reset_user_password(conn.assigns.user, user_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password reset successfully.")
        |> redirect(to: Routes.auth_path(conn, :request, "identity"))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def get_user_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    if user = AccountManager.get_user_by_reset_password_token(token) do
      conn |> assign(:user, user) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Reset password link is invalid or it has expired")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
