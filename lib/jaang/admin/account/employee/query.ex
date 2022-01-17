defmodule Jaang.Admin.Account.Employee.Query do
  import Ecto.Query

  alias Jaang.Admin.Account.Employee.Employee

  def base(), do: Employee

  def with_employee_id(query \\ base(), employee_id) do
    query
    |> where([e], e.id == ^employee_id)
  end
end
