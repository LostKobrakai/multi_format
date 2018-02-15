defmodule MultiFormatTest do
  use ExUnit.Case, async: true
  use RouterHelper

  defmodule UserController do
    use Phoenix.Controller
    def index(conn, _params), do: text(conn, "ok")
    def create(conn, _params), do: text(conn, "ok")
  end

  defmodule Router do
    use Phoenix.Router
    use MultiFormat, match_html: "", match_json: "json"

    pipeline :match_html do
      plug(:put_assigns, pipeline: :html)
    end

    pipeline :match_json do
      plug(:put_assigns, pipeline: :json)
    end

    get("/default", UserController, :index) |> multi()
    get("/custom", UserController, :index) |> multi(match_html: "")
    match(:move, "/match", UserController, :index) |> multi()
    match(:*, "/any", UserController, :index) |> multi()
    resources("/resources", UserController) |> multi()

    def put_assigns(conn, opts) do
      Enum.reduce(opts, conn, &assign(&2, elem(&1, 0), elem(&1, 1)))
    end
  end

  setup do
    Logger.disable(self())
    :ok
  end

  describe "default pairs" do
    test "html route" do
      conn = call(Router, :get, "/default")
      assert conn.assigns[:multi_ext] == ""
      assert conn.resp_body == "ok"
    end

    test "json route" do
      conn = call(Router, :get, "/default.json")
      assert conn.assigns[:multi_ext] == "json"
      assert conn.resp_body == "ok"
    end
  end

  describe "custom pairs" do
    test "html route" do
      conn = call(Router, :get, "/custom")
      assert conn.assigns[:multi_ext] == ""
      assert conn.resp_body == "ok"
    end

    test "json route" do
      assert_raise Phoenix.Router.NoRouteError, fn ->
        call(Router, :get, "/custom.json")
      end
    end
  end

  describe "match macro" do
    test "html route" do
      conn = call(Router, :move, "/match")
      assert conn.assigns[:multi_ext] == ""
      assert conn.resp_body == "ok"
    end

    test "json route" do
      conn = call(Router, :move, "/match.json")
      assert conn.assigns[:multi_ext] == "json"
      assert conn.resp_body == "ok"
    end
  end

  describe "match macro any" do
    test "html route" do
      conn = call(Router, :move, "/any")
      assert conn.assigns[:multi_ext] == ""
      assert conn.resp_body == "ok"
    end

    test "json route" do
      conn = call(Router, :move, "/any.json")
      assert conn.assigns[:multi_ext] == "json"
      assert conn.resp_body == "ok"
    end
  end

  describe "resources" do
    test "html route" do
      conn = call(Router, :get, "/resources")
      assert conn.assigns[:multi_ext] == ""
      assert conn.resp_body == "ok"

      conn = call(Router, :post, "/resources")
      assert conn.assigns[:multi_ext] == ""
      assert conn.resp_body == "ok"
    end

    test "json route" do
      conn = call(Router, :get, "/resources.json")
      assert conn.assigns[:multi_ext] == "json"
      assert conn.resp_body == "ok"

      conn = call(Router, :post, "/resources.json")
      assert conn.assigns[:multi_ext] == "json"
      assert conn.resp_body == "ok"
    end
  end

  describe "pipelines" do
    test "html route" do
      conn = call(Router, :get, "/default")
      assert conn.assigns[:pipeline] == :html
    end

    test "json route" do
      conn = call(Router, :get, "/default.json")
      assert conn.assigns[:pipeline] == :json
    end
  end
end
