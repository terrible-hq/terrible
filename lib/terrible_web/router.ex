defmodule TerribleWeb.Router do
  use TerribleWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TerribleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/", TerribleWeb do
    pipe_through :browser

    get "/", PageController, :home

    sign_in_route()
    sign_out_route(AuthenticationController)
    auth_routes_for(Terrible.Authentication.User, to: AuthenticationController)
    reset_route([])

    live_session :authenticated,
      on_mount: [
        AshAuthentication.Phoenix.LiveSession,
        {TerribleWeb.LiveUserAssigns, :live_user_required}
      ],
      session: {AshAuthentication.Phoenix.LiveSession, :generate_session, []} do
      live "/books", BookLive.Index, :index
      live "/books/new", BookLive.Index, :new
      live "/books/:id/edit", BookLive.Index, :edit
    end

    live_session :authenticated_budgeting,
      layout: {TerribleWeb.Layouts, :book},
      on_mount: [
        AshAuthentication.Phoenix.LiveSession,
        {TerribleWeb.LiveUserAssigns, :live_user_required},
        TerribleWeb.NavigationAssigns
      ],
      session: {AshAuthentication.Phoenix.LiveSession, :generate_session, []} do
      live "/books/:book_id/budgets/:name", BudgetLive.Show, :show

      live "/books/:book_id/budgets/:name/accounts/new", BudgetLive.Show, :new_account

      live "/books/:book_id/budgets/:name/accounts/:account_id/edit",
           BudgetLive.Show,
           :edit_account

      live "/books/:book_id/budgets/:name/categories/new", BudgetLive.Show, :new_category

      live "/books/:book_id/budgets/:name/categories/:category_id/edit",
           BudgetLive.Show,
           :edit_category

      live "/books/:book_id/budgets/:name/categories/:category_id/envelopes/new",
           BudgetLive.Show,
           :new_envelope

      live "/books/:book_id/budgets/:name/categories/:category_id/envelopes/:envelope_id/edit",
           BudgetLive.Show,
           :edit_envelope
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", TerribleWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:terrible, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TerribleWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
