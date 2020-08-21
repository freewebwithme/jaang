defmodule JaangWeb.RegisterController do
  use JaangWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, params) do
    IO.puts("Inspecting register params")
    IO.inspect(params)

    conn
    |> redirect(to: "/")
  end
end
