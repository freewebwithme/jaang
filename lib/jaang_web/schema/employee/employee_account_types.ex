defmodule JaangWeb.Schema.Employee.EmployeeAccountTypes do
  use Absinthe.Schema.Notation

  alias Jaang.Admin.Account.Employee.EmployeeAccounts
  alias Jaang.Product.Products
  alias JaangWeb.Resolvers.Employee.EmployeeAccountResolver
  alias JaangWeb.Schema.Middleware

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :employee_account_mutations do
    @desc "Register an employee"
    field :sign_up_employee, :employee_session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:password_confirmation, non_null(:string))
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
      arg(:phone, non_null(:string))

      # middleware(Middleware.AuthenticateEmployee)

      resolve(&EmployeeAccountResolver.sign_up_employee/3)
    end

    @desc "Log in an employee"
    field :log_in_employee, :employee_session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&EmployeeAccountResolver.log_in_employee/3)
    end

    @desc "Reset password"
    field :reset_password, :simple_response do
      arg(:email, non_null(:string))

      resolve(&EmployeeAccountResolver.reset_password/3)
    end

    @desc "Send confirmation email from Flutter"
    field :resend_confirmation_email, :simple_response do
      arg(:employee_token, non_null(:string))

      resolve(&EmployeeAccountResolver.resend_confirmation_email/3)
    end

    @desc "Log out"
    field :log_out, :employee_session do
      arg(:token, :string)
      middleware(Middleware.Authenticate)

      resolve(&EmployeeAccountResolver.log_out/3)
    end

    @desc "Verify session token from client"
    field :verify_token, :employee_session do
      arg(:token, non_null(:string))

      resolve(&EmployeeAccountResolver.verify_token/3)
    end
  end

  object :employee_session do
    field :employee, :employee
    field :token, :string
    field :expired, :boolean, default_value: false
  end

  object :employee do
    field :id, :id
    field :stripe_id, :string
    field :email, :string
    field :confirmed_at, :string
    field :employee_profile, :employee_profile, resolve: dataloader(EmployeeAccounts)
    field :roles, list_of(:employee_role), resolve: dataloader(EmployeeAccounts)
    field :invoices, list_of(:invoice), resolve: dataloader(Products)
  end

  object :employee_profile do
    field :first_name, :string
    field :last_name, :string
    field :photo_url, :string

    field :phone, :string do
      resolve(fn parent, _, _ ->
        phone_number = Map.get(parent, :phone)

        cond do
          is_nil(phone_number) || phone_number == "" ->
            {:ok, phone_number}

          true ->
            area_code = String.slice(phone_number, 0, 3)
            head = String.slice(phone_number, 3, 3)
            tail = String.slice(phone_number, 6, 4)
            formatted = "(#{area_code})#{head}-#{tail}"
            {:ok, formatted}
        end
      end)
    end
  end

  object :employee_role do
    field :name, :string
  end
end
