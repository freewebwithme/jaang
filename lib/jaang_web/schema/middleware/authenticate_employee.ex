defmodule JaangWeb.Schema.Middleware.AuthenticateEmployee do
  @behaviour Absinthe.Middleware

  def call(resolution, _) do
    case resolution.context do
      %{current_employee: _} ->
        resolution

      _ ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "Employee can only access"})
    end
  end
end
