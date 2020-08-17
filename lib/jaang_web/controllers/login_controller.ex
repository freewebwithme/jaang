defmodule JaangWeb.LoginController do
  use JaangWeb, :controller

  def index(conn, _prams) do
    render(conn, "index.html")
  end
end
