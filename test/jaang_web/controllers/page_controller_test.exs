defmodule JaangWeb.PageControllerTest do
  use JaangWeb.ConnCase

  describe "index" do
    test "Landing page", %{conn: conn} do
      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "A better way to shop groceries"
    end
  end
end
