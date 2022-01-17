defmodule JaangWeb.Admin.EmployeeResetPasswordController do
  use JaangWeb, :controller
  alias Jaang.Admin.EmployeeAccountManager

  plug :get_employee_by_reset_password_token when action in [:edit, :update]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"employee" => %{"email" => email}}) do
    if user = EmployeeAccountManager.get_employee_by_email(email) do
      EmployeeAccountManager.deliver_employee_reset_password_instructions(
        user,
        &Routes.employee_reset_password_url(conn, :edit, &1)
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
    render(conn, "edit.html",
      changeset: EmployeeAccountManager.change_employee_password(conn.assigns.employee, %{})
    )
  end

  def update(conn, %{"employee" => employee_params}) do
    case EmployeeAccountManager.reset_employee_password(conn.assigns.employee, employee_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password reset successfully.")
        |> redirect(to: "/")

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def get_employee_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    if employee = EmployeeAccountManager.get_employee_by_reset_password_token(token) do
      conn |> assign(:employee, employee) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Reset password link is invalid or it has expired")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
