defmodule JaangWeb.Admin.EmployeeAccountConfirmationController do
  use JaangWeb, :controller
  alias Jaang.Admin.EmployeeAccountManager

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"employee" => %{"email" => email}}) do
    if employee = EmployeeAccountManager.get_employee_by_email(email) do
      EmployeeAccountManager.deliver_employee_confirmation_instructions(
        employee,
        &Routes.employee_account_confirmation_url(conn, :confirm, &1)
      )
    end

    # Regardless of the outcome, show an impartial success/error message
    conn
    |> put_flash(
      :info,
      "If your e-mail is in our system and it has not been confirmed yet, " <>
        "you will receive an e-mail with instructions shortly"
    )
    |> redirect(to: "/")
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def confirm(conn, %{"token" => token}) do
    case EmployeeAccountManager.confirm_employee(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Account confirmed successfully.")
        |> redirect(to: "/")

      :error ->
        conn
        |> put_flash(:error, "Confirmation link is invalid or it has expired")
        |> redirect(to: "/")
    end
  end
end
