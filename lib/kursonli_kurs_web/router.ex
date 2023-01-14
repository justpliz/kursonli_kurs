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

  pipeline :admin_app do
    plug :put_root_layout, {KursonliKursWeb.LayoutView, "admin_app.html"}
  end

  pipeline :all_app do
    plug :put_root_layout, {KursonliKursWeb.LayoutView, "all_app.html"}
  end

  pipeline :clean do
    plug :put_root_layout, {KursonliKursWeb.LayoutView, "clean.html"}
  end

  pipeline :index do
    plug :put_root_layout, {KursonliKursWeb.LayoutView, "index_app.html"}
  end

  scope "/", KursonliKursWeb do
    pipe_through [:browser, :index]

    get "/", PageController, :index
  end

  scope "/admin", KursonliKursWeb do
    # pipe_through :browser
    pipe_through [:browser, :clean]

    get "/login", AdminController, :login_form
    post "/login", AdminController, :login_form_submit
  end

  scope "/admin", KursonliKursWeb do
    pipe_through [:browser, :admin_check, :admin_app]

    get "/", AdminController, :index
    get "/logout", AdminController, :admin_logout

    get "/register_org", AdminController, :register_org
    post "/register_org_submit", AdminController, :register_org_submit
  end

  scope "/worker", KursonliKursWeb do
    pipe_through [:browser, :clean]

    get "/login", WorkerController, :login_form
    post "/login", WorkerController, :login_form_submit
  end

  scope "/worker", KursonliKursWeb do
    pipe_through [:browser, :worker_check, :all_app]

    get "/", WorkerController, :index
    get "/update_pass", WorkerController, :update_pass
    post "/update_pass", WorkerController, :update_pass_submit
    get "/logout", WorkerController, :worker_logout

    get "/orders", WorkerController, :orders
    get "/create_order", WorkerController, :create_order
    post "/create_order", WorkerController, :create_order_submit
    get "/courses", WorkerController, :courses
    post "/update_course", WorkerController, :update_course
    get "/delete_order", WorkerController, :delete_order
    get "/create_course", WorkerController, :create_course
    post "/create_course", WorkerController, :create_course_submit
    get "/delete_course", WorkerController, :delete_course
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
