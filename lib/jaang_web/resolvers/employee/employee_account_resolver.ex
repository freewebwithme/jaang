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
      profile: %{first_name: first_name, last_name: last_name, phone: phone}
    }

    case EmployeeAccountManager.create_employee_with_profile(attrs) do
      {:ok, employee} ->
        Jaang.EmailManager.send_welcome_email(employee)
        {:ok, employee, token} = EmployeeAuthMobile.log_in_mobile_employee(email, password)

        {:ok, %{employee: employee, token: token, expired: false}}

      _ ->
        {:error, "Can't register, please try again"}
    end
  end
end
