defmodule RapydCheckoutExampleWeb.Router do
  use RapydCheckoutExampleWeb, :router

  import RapydCheckoutExampleWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {RapydCheckoutExampleWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RapydCheckoutExampleWeb do
    pipe_through :browser

    live "/", PageLive, :index
    get "/products", ProductController, :index
    get "/products/hosted-checkout", ProductController, :hosted_checkout
    get "/products/toolkit-checkout", ProductController, :toolkit_checkout
    get "/testing", TestingController, :index
    post "/checkout-redirect", ProductController, :checkout_redirect
    get "/checkout", ProductController, :checkout
  end

  # Other scopes may use custom stacks.
  # scope "/api", RapydCheckoutExampleWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Application.get_env(:rapyd_checkout_example, :env) in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard",
        metrics: RapydCheckoutExampleWeb.Telemetry,
        ecto_repos: [RapydCheckoutExample.Repo]
    end
  end

  ## Authentication routes

  scope "/", RapydCheckoutExampleWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated, :put_session_layout]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", RapydCheckoutExampleWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", RapydCheckoutExampleWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end
end
