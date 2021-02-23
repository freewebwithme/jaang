defmodule JaangWeb.Resolvers.Employee.EmployeeAccountResolver do
  alias Jaang.Admin.Account.EmployeeAuthMobile
  alias Jaang.Admin.EmployeeAccountManager

  def sign_up_employee(_, args, _) do
    %{
      email: email,
      password: password,
      password_confirmation: password_confirmation,
      first_name: first_name,
      last_name: last_name,
      phone: phone
    } = args

    # Remap for profile
    attrs = %{
      email: email,
      password: password,
      password_confirmation: password_confirmation,
      employee_profile: %{first_name: first_name, last_name: last_name, phone: phone}
    }

    case EmployeeAccountManager.create_employee_with_profile(attrs) do
      {:ok, employee} ->
        Jaang.EmailManager.send_welcome_email(employee)
        {:ok, employee, token} = EmployeeAuthMobile.log_in_mobile_employee(email, password)

        {:ok, %{employee: employee, token: token, expired: false}}

      {:error, error} ->
        {:error, error}
    end
  end

  def log_in_employee(_, %{email: email, password: password}, _) do
    case EmployeeAuthMobile.log_in_mobile_employee(email, password) do
      {:ok, employee, token} ->
        # get cart or create new
        # carts = OrderManager.get_all_carts_or_create_new(user)
        {:ok, %{employee: employee, token: token, expired: false}}

      _ ->
        {:error, "Can't log in"}
    end
  end

  def reset_password(_, %{email: email}, _) do
    if employee = EmployeeAccountManager.get_employee_by_email(email) do
      EmployeeAccountManager.deliver_employee_reset_password_instructions(
        employee,
        &JaangWeb.Router.Helpers.employee_reset_password_url(JaangWeb.Endpoint, :edit, &1)
      )

      {:ok, %{sent: true, message: "email sent"}}
    else
      {:ok, %{sent: false, message: "email not sent"}}
    end
  end

  def resend_confirmation_email(_, %{employee_token: token}, _) do
    employee = EmployeeAccountManager.get_employee_by_session_token(token)

    if employee.confirmed_at do
      {:ok, %{sent: false, message: "email not sent"}}
    else
      # Resend confirmation email
      EmployeeAccountManager.deliver_employee_confirmation_instructions(
        employee,
        &JaangWeb.Router.Helpers.employee_account_confirmation_url(
          JaangWeb.Endpoint,
          :confirm,
          &1
        )
      )

      {:ok, %{sent: true, message: "email sent"}}
    end
  end

  @doc """
  Verify session token from client
  """
  def verify_token(_, %{token: token}, _) do
    case EmployeeAuthMobile.get_employee_by_session_token(token) do
      {:ok, employee} ->
        # get cart or create new
        # carts = OrderManager.get_all_carts_or_create_new(user)

        {:ok, %{employee: employee, token: token, expired: false}}

      {:error, _} ->
        {:ok, %{employee: nil, token: token, expired: true}}
    end
  end

  @doc """
  Log a employee out
  Delete session token from database and return empty session
  """
  def log_out(_, %{token: token}, _) do
    case EmployeeAuthMobile.delete_session_token(token) do
      {:ok, _struct} ->
        {:ok, %{employee: nil, token: nil, expired: true}}

      {:error, _changeset} ->
        {:error, "Can't delete session token"}
    end
  end
end
