defmodule Jaang.Admin.Account.Employee.EmployeeAccounts do
  alias Jaang.Admin.Account.Employee.{Employee, EmployeeToken}
  alias Jaang.{Repo, EmailManager}
  alias Jaang.Account.Validator

  def create_employee(attrs) do
    %Employee{}
    |> Employee.registration_changeset(attrs)
    |> Repo.insert!()
  end

  def get_admin_user(id) do
    Repo.get_by(AdminUser, id: id)
  end

  def delete_employee(%Employee{} = employee) do
    Repo.delete!(employee)
  end

  def update_employee(employee, attrs) do
    employee
    |> Employee.changeset(attrs)
    |> Repo.update!()
  end

  @doc """
  Log in a employee using email and password

  ## Examples

      iex> get_employee_by_email_and_password("foo@example.com", "secret")
      %User{}

      iex> get_employee_by_email_and_password("foo@example.com", "wrong")
      nil
  """

  def get_employee_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(Employee, email: email)
    if Validator.valid_password?(user, password), do: user
  end

  def get_employee_by_email(email) when is_binary(email) do
    Repo.get_by(Employee, email: email)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the employee password.

  ## Examples

      iex> change_employee_password(employee)
      %Ecto.Changeset{data: %Employee{}}

  """
  def change_employee_password(employee, attrs \\ %{}) do
    Employee.password_changeset(employee, attrs)
  end

  @doc """
  Delivers the update e-mail instructions to the given employee.

  ## Examples

      iex> deliver_update_email_instructions(employee, current_email, &Routes.employee_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(
        %Employee{} = employee,
        current_email,
        update_email_url_fun
      )
      when is_function(update_email_url_fun, 1) do
    {encoded_token, employee_token} =
      EmployeeToken.build_email_token(employee, "change:#{current_email}")

    Repo.insert!(employee_token)

    # TODO: send email
  end

  ## Confirmation

  @doc """
  Delivers the confirmation e-mail instructions to the given employee.

  ## Examples

      iex> deliver_employee_confirmation_instructions(employee, &Routes.employee_confirmation_url(conn, :confirm, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_employee_confirmation_instructions(confirmed_employee, &Routes.employee_confirmation_url(conn, :confirm, &1))
      {:error, :already_confirmed}

  """

  def deliver_employee_confirmation_instructions(%Employee{} = employee, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if employee.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, employee_token} = EmployeeToken.build_email_token(employee, "confirm")
      Repo.insert!(employee_token)
      url = confirmation_url_fun.(encoded_token)

      # TODO: # Send email
      EmailManager.send_confirmation_instructions(employee, url)
    end
  end

  @doc """
  Confirms a employee by the given token.

  If the token matches, the employee account is marked as confirmed
  and the token is deleted.
  """
  def confirm_employee(token) do
    with {:ok, query} <- EmployeeToken.verify_email_token_query(token, "confirm"),
         %Employee{} = employee <- Repo.one(query),
         {:ok, %{employee: employee}} <- Repo.transaction(confirm_employee_multi(employee)) do
      {:ok, employee}
    else
      _ -> :error
    end
  end

  defp confirm_employee_multi(employee) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:employee, Employee.confirm_changeset(employee))
    |> Ecto.Multi.delete_all(
      :tokens,
      EmployeeToken.user_and_contexts_query(employee, ["confirm"])
    )
  end

  ## Reset password

  @doc """
  Gets the employee by reset password token.

  ## Examples

      iex> get_employee_by_reset_password_token("validtoken")
      %Employee{}

      iex> get_employee_by_reset_password_token("invalidtoken")
      nil

  """
  def get_employee_by_reset_password_token(token) do
    with {:ok, query} <- EmployeeToken.verify_email_token_query(token, "reset_password"),
         %Employee{} = employee <- Repo.one(query) do
      employee
    else
      _ -> nil
    end
  end

  @doc """
  Delivers the reset password e-mail to the given employee.

  ## Examples

      iex> deliver_employee_reset_password_instructions(employee, &Routes.employee_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_employee_reset_password_instructions(%Employee{} = employee, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, employee_token} = EmployeeToken.build_email_token(employee, "reset_password")

    Repo.insert!(employee_token)
    url = reset_password_url_fun.(encoded_token)
    # Send email
    EmailManager.send_reset_password_email(employee, url)
  end

  @doc """
  Resets the employee password.

  ## Examples

      iex> reset_employee_password(employee, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Employee{}}

      iex> reset_employee_password(employee, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_employee_password(employee, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:employee, Employee.password_changeset(employee, attrs))
    |> Ecto.Multi.delete_all(:tokens, EmployeeToken.user_and_contexts_query(employee, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{employee: employee}} -> {:ok, employee}
      {:error, :employee, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_employee_session_token(employee) do
    {token, employee_token} = EmployeeToken.build_session_token(employee)
    Repo.insert!(employee_token)
    token
  end

  def delete_session_token(token) do
    Repo.delete_all(EmployeeToken.token_and_context_query(token, "session"))
    :ok
  end

  @doc """
  Gets the employee with the given signed token.
  """
  def get_employee_by_session_token(token) do
    {:ok, query} = EmployeeToken.verify_session_token_query(token)
    Repo.one(query)
  end
end
