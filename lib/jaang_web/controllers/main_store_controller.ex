defmodule JaangWeb.MainStoreController do
  use JaangWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
