defmodule JaangWeb.Router do
  use JaangWeb, :router

  import JaangWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {JaangWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", JaangWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/newsletter", NewsletterController, :index
    delete "/log_out", AuthController, :delete
    # account confirmation
    get "/account/confirm", AccountConfirmationController, :new
    post "/account/confirm", AccountConfirmationController, :create
    get "/account/confirm/:token", AccountConfirmationController, :confirm
  end

  scope "/store", JaangWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/", MainLive
  end

  scope "/auth", JaangWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/register", RegisterController, :index
    post "/register", RegisterController, :create

    # Reset password
    get "/reset_password", ResetPasswordController, :new
    post "/reset_password", ResetPasswordController, :create
    get "/reset_password/:token", ResetPasswordController, :edit
    put "/reset_password/:token", ResetPasswordController, :update

    # Log in
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/identity/callback", AuthController, :identity_callback
  end

  forward "/api", Absinthe.Plug, schema: JaangWeb.Schema

  if Mix.env() == :dev do
    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: JaangWeb.Schema,
      socket: JaangWeb.UserSocket
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router
    forward "/sent_emails", Bamboo.SentEmailViewerPlug

    scope "/" do
      pipe_through :browser
      live_dashboard "/live/dashboard", metrics: JaangWeb.Telemetry
    end
  end
end
