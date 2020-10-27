defmodule JaangWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: JaangWeb.Schema

  alias Jaang.Account.UserAuthMobile

  ## Channels
  # channel "room:*", JaangWeb.RoomChannel

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
  def connect(%{"token" => token} = params, socket, _connect_info) do
    IO.puts("Inspecting socket params")
    IO.inspect(params)

    with {:ok, user} <- UserAuthMobile.get_user_by_session_token(token) do
      socket = Absinthe.Phoenix.Socket.put_options(socket, context: %{current_user: user})
      IO.puts(" Has current user")
      {:ok, socket}
    else
      _ ->
        {:ok, socket}
    end
  end

  # def connect(_params, socket, _connect_info) do
  #  {:ok, socket}
  # end

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
