defmodule Jaang.Admin.Account.EmployeeAuthMobile do
  @moduledoc """
  User authentication module for Graphql API
  """
  alias Jaang.Admin.EmployeeAccountManager
  alias Jaang.Repo
  import Ecto.Query

  @doc """
  Log in a employee using email and password
  If success, save EmployeeToken schema to database.
  and return employee schema and token
  """
  def log_in_mobile_employee(email, password) do
    if employee = EmployeeAccountManager.get_employee_by_email_and_password(email, password) do
      token = generate_employee_session_token(employee)
      {:ok, employee, token}
    else
      {:error, "Can't log in"}
    end
  end

  def generate_employee_session_token(employee) do
    {token, employee_token} = build_session_token(employee)
    Repo.insert!(employee_token)
    token
  end

  @salt "jaang employee token"
  def build_session_token(employee) do
    token = Phoenix.Token.sign(JaangWeb.Endpoint, @salt, %{id: employee.id})

    {token,
     %Jaang.Admin.Account.Employee.EmployeeToken{
       token: token,
       context: "session",
       employee_id: employee.id
     }}
  end

  def delete_session_token(token) do
    employee_token = token_and_context_query(token, "session") |> Repo.one()

    if employee_token do
      case Repo.delete(employee_token) do
        {:ok, struct} -> {:ok, struct}
        {:error, changeset} -> {:error, changeset}
      end
    end
  end

  @session_validity_in_days 60
  # 60 days
  @max_age 24 * 60 * 60 * 60

  def verify_session_token_query(token) do
    case Phoenix.Token.verify(JaangWeb.Endpoint, @salt, token, max_age: @max_age) do
      {:ok, _employee_id} ->
        query =
          from token in token_and_context_query(token, "session"),
            join: employee in assoc(token, :employee),
            where: token.inserted_at > ago(@session_validity_in_days, "day"),
            select: employee

        {:ok, query}

      {:error, _} ->
        nil
    end
  end

  def get_employee_by_session_token(token) do
    with {:ok, query} <- verify_session_token_query(token),
         %{} = employee <- Repo.one(query) |> Repo.preload(:profile) do
      {:ok, employee}
    else
      nil -> {:error, "Can't find a employee"}
    end
  end

  def token_and_context_query(token, context) do
    from Jaang.Admin.Account.Employee.EmployeeToken, where: [token: ^token, context: ^context]
  end
end
