defmodule MultiFormat do
  @moduledoc """
  `MultiFormat` is a helper for `Phoenix.Router` when working with multi format 
  routes.

  It allows routes to match for one or more extentions (or none) without
  having to manually define all of them and assigning pipelines with the 
  matching `plug :accepts, …`.

  ## Examples

  The router:

      defmodule MyAppWeb.Router do
        use MyAppWeb, :router
        # Use MultiFormat and supply default pipeline/ext pairs
        use MultiFormat, match_html: "", match_json: "json"

        pipeline :browser […]

        pipeline :match_html do # :html would conflict with the Phoenix.Controller imports
          plug(:accepts, ["html"])
        end

        pipeline :match_json do # :json would conflict with the Phoenix.Controller imports
          plug(:accepts, ["json"])
        end

        scope "/", MyAppWeb do
          # Use the default browser stack
          pipe_through(:browser)

          get("/", PageController, :index)

          # Does allow for `/test` and `/test.json` based in the default pairs
          # Does work with all the macros of Phoenix.Router
          get("/test", PageController, :index) |> multi()

          # Does allow only `/test2.json` based on the explicitly given pair
          get("/test2", PageController, :index) |> multi(jason: "json")
        end
      end

  The controller:

      defmodule MyAppWeb.PageController do
        use MyAppWeb, :controller

        # Overriding `action/2` makes matching on extentions easier
        def action(conn, _) do
          args = [conn, conn.params, conn.assigns]
          apply(__MODULE__, action_name(conn), args)
        end

        # Match for the extentionless html setup
        def index(conn, _params, %{match_ext: ""}) do
          render(conn, "index.html")
        end

        # Match for the json route
        def index(conn, _params, %{match_ext: "json"}) do
          render(conn, "index.json")
        end
      end

  """
  defmacro __using__(opts \\ []) do
    opts = Enum.uniq_by(opts, fn {_pipeline, ext} -> ext end)
    Module.put_attribute(__CALLER__.module, :multi_format_opts, opts)

    quote do
      import MultiFormat
    end
  end

  defmacro multi(ast, opts \\ nil) do
    opts =
      case opts do
        nil -> Module.get_attribute(__CALLER__.module, :multi_format_opts)
        opts -> Enum.uniq_by(opts, fn {_pipeline, ext} -> ext end)
      end

    handle_path = fn
      "/", _ ->
        raise ArgumentError, "Does only work with non-root paths."

      path, ext ->
        case Path.basename(path) do
          "*" <> _ ->
            raise ArgumentError, "Does not work with wildcard paths."

          ":" <> _ ->
            raise ArgumentError, "Does not work with paths ending with params."

          _ ->
            dotted_ext = if ext == "", do: "", else: ".#{ext}"
            path <> dotted_ext
        end
    end

    build_scope = fn route, pipeline, ext ->
      quote do
        scope "/", assigns: %{multi_ext: unquote(ext)} do
          pipe_through(unquote(pipeline))
          unquote(route)
        end
      end
    end

    case ast do
      {:match, meta, [method, path | rest]} ->
        Enum.map(opts, fn {pipeline, ext} ->
          {:match, meta, [method, handle_path.(path, ext) | rest]}
          |> build_scope.(pipeline, ext)
        end)

      {method, meta, [path | rest]} ->
        Enum.map(opts, fn {pipeline, ext} ->
          {method, meta, [handle_path.(path, ext) | rest]}
          |> build_scope.(pipeline, ext)
        end)
    end
  end
end
