defmodule JaangWeb.EmployeeSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: JaangWeb.Schema

  alias Jaang.Admin.Account.EmployeeAuthMobile

  ## Channels
  channel "store:*", JaangWeb.StoreChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(%{"token" => token} = _params, socket, _connect_info) do

    with {:ok, employee} <- EmployeeAuthMobile.get_employee_by_session_token(token) do
      IO.puts("Found current employee")
      {:ok, assign(socket, :current_employee, employee)}
    else
      _ ->
        IO.puts("Can't find an employee")
        {:ok, socket}
    end
  end

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     JaangWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil
end
