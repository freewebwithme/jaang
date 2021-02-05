defmodule JaangWeb.Router do
  use JaangWeb, :router

  import JaangWeb.UserAuth
  import JaangWeb.Admin.AdminUserAuth, only: [fetch_admin_user: 2]

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
    plug JaangWeb.Plugs.SetCurrentUser
  end

  pipeline :dashboard do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {JaangWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_admin_user
    plug JaangWeb.Plugs.AuthorizeAdmin
  end

  scope "/admin", JaangWeb.Admin do
    pipe_through :dashboard

    live "/", Home.HomeLive
    live "/orders", Orders.OrdersLive
    live "/orders/detail/:id", Orders.OrderDetailLive

    live "/partners", Partners.PartnersOverviewLive
    live "/partners/:store_id", Partners.PartnerLive
    live "/partners/orders/:store_name/:order_id/detail", Partners.PartnerOrderDetailLive

    live "/products", Products.ProductsLive
    live "/products/:store_name/list", Products.ProductsListLive
    live "/products/:store_name/search/", Products.ProductSearchResultLive
    live "/products/detail/:store_id/:product_id", Products.ProductDetailLive
    live "/products/detail/:store_id/edit/:product_id", Products.ProductEditDetailLive

    live "/customers", Customers.CustomersLive

    live "/employees", Employees.EmployeesOverviewLive
    live "/employees/shoppers", Employees.ShoppersLive
    live "/employees/drivers", Employees.DriversLive

    live "/customer-services", CustomerServices.CustomerServicesOverviewLive
    live "/customer-services/messages", CustomerServices.CustomerServiceMessagesLive
    live "/customer-services/refund-request", CustomerServices.CustomerServiceRefundRequestsLive
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

    # Staff login
    live "/staff-login", Admin.StaffLoginLive
    post "/staff-login", Admin.AdminAuthController, :log_in
    post "/staff-logout", Admin.AdminAuthController, :log_out
  end

  scope "/store", JaangWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/", MainStoreController, :index
    # live "/", MainLive
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

  scope "/" do
    pipe_through :api

    forward "/api", Absinthe.Plug, schema: JaangWeb.Schema

    if Mix.env() == :dev do
      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: JaangWeb.Schema,
        socket: JaangWeb.UserSocket
    end
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
