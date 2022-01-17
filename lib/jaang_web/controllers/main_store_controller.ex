defmodule JaangWeb.MainStoreController do
  use JaangWeb, :controller

  def index(conn, _params) do
    IO.inspect(conn)
    render(conn, "index.html")
  end
end
