defmodule JaangWeb.RegisterLive do
  use JaangWeb, :live_view
  alias Jaang.AccountManager

  def mount(_params, _session, socket) do
    changeset = AccountManager.change_user(%Jaang.Account.User{})
    socket = assign(socket, changeset: changeset)
    {:ok, socket}
  end

  def handle_event("register", %{"user" => params}, socket) do
    IO.puts("inspecting assigns")
    IO.inspect(params)

    changeset = AccountManager.change_user(%Jaang.Account.User{})
    IO.puts("inspecting changeset")
    IO.inspect(changeset)
    socket = assign(socket, changeset: changeset)

    {:noreply, socket}
  end
end
