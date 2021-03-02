defmodule Jaang.Admin.EmployeeAccountManager do
  alias Jaang.Admin.Account.Employee.EmployeeAccounts

  defdelegate create_employee(attrs), to: EmployeeAccounts
  defdelegate create_employee_with_profile(attrs), to: EmployeeAccounts
  defdelegate delete_employee(employee), to: EmployeeAccounts
  defdelegate update_employee(employee, attrs), to: EmployeeAccounts
  defdelegate get_employee_by_email_and_password(email, password), to: EmployeeAccounts
  defdelegate get_employee_by_email(email), to: EmployeeAccounts
  defdelegate get_employee(id), to: EmployeeAccounts
  defdelegate change_employee_password(employee, attrs), to: EmployeeAccounts
  defdelegate change_employee(employee, attrs), to: EmployeeAccounts

  defdelegate deliver_update_email_instructions(employee, current_email, update_email_url_fun),
    to: EmployeeAccounts

  defdelegate deliver_employee_confirmation_instructions(employee, confirmation_url_fun),
    to: EmployeeAccounts

  defdelegate confirm_employee(token), to: EmployeeAccounts
  defdelegate get_employee_by_reset_password_token(token), to: EmployeeAccounts

  defdelegate deliver_employee_reset_password_instructions(employee, reset_password_url_fun),
    to: EmployeeAccounts

  defdelegate reset_employee_password(employee, attrs), to: EmployeeAccounts
  defdelegate generate_employee_session_token(employee), to: EmployeeAccounts
  defdelegate delete_session_token(token), to: EmployeeAccounts
  defdelegate get_employee_by_session_token(token), to: EmployeeAccounts

  defdelegate list_employees(criteria), to: EmployeeAccounts

  # Roles
  defdelegate create_employee_role(attrs), to: EmployeeAccounts
  defdelegate get_employee_role(id), to: EmployeeAccounts
  defdelegate update_employee_role(employee_role, attrs), to: EmployeeAccounts
  defdelegate delete_employee_role(employee_role), to: EmployeeAccounts
  defdelegate change_employee_role(employee_role, attrs), to: EmployeeAccounts
  defdelegate list_roles(), to: EmployeeAccounts
end
