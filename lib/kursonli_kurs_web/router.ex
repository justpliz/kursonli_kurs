defmodule KursonliKursWeb.Router do
  use KursonliKursWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {KursonliKursWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug(KursonliKursWeb.PlugLocal)
  end

  pipeline(:admin_check) do
    plug(KursonliKurs.Auth.AdminCheck)
    plug :fetch_session
  end

  pipeline(:worker_check, do: plug(KursonliKurs.Auth.WorkerCheck))

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin_app do
    plug :put_root_layout, {KursonliKursWeb.LayoutView, "admin_app.html"}
  end

  pipeline :worker_app do
    plug :put_root_layout, {KursonliKursWeb.LayoutView, "worker_app.html"}
  end

  pipeline :clean do
    plug :put_root_layout, {KursonliKursWeb.LayoutView, "clean.html"}
  end

  pipeline :index do
    plug :put_root_layout, {KursonliKursWeb.LayoutView, "index_app.html"}
  end

  scope "/", KursonliKursWeb do
    pipe_through [:browser, :index]

    get "/", PageController, :redirect_almaty
    get "/city", PageController, :index
    get "/personal", PageController, :personal_page

    get "/instruction", PageController, :instruction
  end

  scope "/api/v1", KursonliKursWeb do
    pipe_through [:api]
    post "/trade", TradeController, :ajax_update_message_map
    delete "/chat", TradeController, :delete_chat
  end

  scope "/admin", KursonliKursWeb do
    pipe_through [:browser, :clean]

    get "/login", AdminController, :login_form
    post "/login", AdminController, :login_form_submit
  end

  scope "/trades", KursonliKursWeb do
    pipe_through [:browser]
    post "/", TradeController, :create_trade
    get "/delete", TradeController, :delete_trade
  end

  scope "/admin", KursonliKursWeb do
    pipe_through [:browser, :admin_check, :admin_app]

    get "/", AdminController, :index
    get "/settings", AdminController, :settings

    get "/logout", AdminController, :admin_logout

    post "/register_org_submit", AdminController, :register_org_submit
    get "/update_org_status", AdminController, :update_org_status

    scope "/currencies" do
      post "/", AdminController, :create_currency_submit
      get "/update", AdminController, :update_currency
      get "/delete", AdminController, :delete_currency
    end

    scope "/cities" do
      post "/", AdminController, :create_city_submit
      get "/update", AdminController, :update_city
      get "/delete", AdminController, :delete_city
    end

    scope "/filials" do
      get "/", AdminController, :filials
      post "/", AdminController, :create_filial_submit
      post "/update", AdminController, :update_filial
      get "/update_filial_status", AdminController, :update_filial_status
      post "/update_filial_tariff", AdminController, :update_filial_tariff
      get "/reset_password", AdminController, :reset_password
    end

    scope "/tariffs" do
      post "/", TariffController, :create_tariff
      get "/update", TariffController, :update_tariff
      get "/delete", TariffController, :delete_tariff
    end

    scope "/notifications" do
      post "/update", AdminController, :update_notification
    end
  end

  scope "/worker", KursonliKursWeb do
    pipe_through [:browser, :clean]

    get "/login", WorkerController, :login_form
    post "/login", WorkerController, :login_form_submit
  end

  scope "/worker", KursonliKursWeb do
    pipe_through [:browser, :worker_check, :worker_app]

    scope "/lang" do
      get("/rus", WorkerController, :select_rus)
      get("/kaz", WorkerController, :select_kaz)
    end

    get "/update_pass", WorkerController, :update_pass
    post "/update_pass", WorkerController, :update_pass_submit
    get "/logout", WorkerController, :worker_logout
    get "/chat", WorkerController, :get_all_message_chat_worker_id

    get "/orders", WorkerController, :orders
    # get "/create_order", WorkerController, :create_order
    post "/create_order", WorkerController, :create_order_submit
    post "/update_order", WorkerController, :update_order
    get "/delete_order", WorkerController, :delete_order

    get "/courses", WorkerController, :courses
    post "/update_course", WorkerController, :update_course
    post "/new_courses", WorkerController, :new_courses
    get "/delete_course", WorkerController, :delete_course

    scope "/settings" do
      get "/", WorkerController, :settings
      post "/update", WorkerController, :update_setting
    end

    get "/payment", WorkerController, :payment
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
