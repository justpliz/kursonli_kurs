defmodule KursonliKursWeb.Router do
  use KursonliKursWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {KursonliKursWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline(:admin_check, do: plug(KursonliKurs.Auth.AdminCheck))

  pipeline(:worker_check, do: plug(KursonliKurs.Auth.WorkerCheck))

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KursonliKursWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/admin", KursonliKursWeb do
    pipe_through :browser

    get "/login", AdminController, :login_form
    post "/login", AdminController, :login_form_submit
  end

  scope "/admin", KursonliKursWeb do
    pipe_through ([:browser, :admin_check])

    get "/", AdminController, :index
    get "/logout", AdminController, :admin_logout

    get "/register_org", AdminController, :register_org
    post "/register_org_submit", AdminController, :register_org_submit
  end

  scope "/worker", KursonliKursWeb do
    pipe_through :browser

    get "/login", WorkerController, :login_form
    post "/login", WorkerController, :login_form_submit
  end

  scope "/worker", KursonliKursWeb do
    pipe_through ([:browser, :worker_check])

    get "/", WorkerController, :index
    get "/update_pass", WorkerController, :update_pass
    post "/update_pass", WorkerController, :update_pass_submit
    get "/logout", WorkerController, :worker_logout
    get "/courses", WorkerController, :courses
    post "/update_course", WorkerController, :update_course

  end

  # Other scopes may use custom stacks.
  # scope "/api", KursonliKursWeb do
  #   pipe_through :api
  # end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
