defmodule JaangWeb.Admin.HomeLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Account.AdminUser

  def mount(_params, _session, socket) do
    changeset = AdminUser.changeset(%AdminUser{}, %{})

    {:ok, assign(socket, changeset: changeset)}
  end
end
