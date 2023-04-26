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

  #       # #    # #####  ###### #    #
  #       # ##   # #    # #       #  #
  #       # # #  # #    # #####    ##
  #       # #  # # #    # #        ##
  #       # #   ## #    # #       #  #
  #       # #    # #####  ###### #    #

  scope "/", KursonliKursWeb do
    pipe_through [:browser, :index]

    get "/", PageController, :redirect_almaty
    get "/city", PageController, :index
    get "/personal", PageController, :personal_page

    get "/instruction_rus", PageController, :instruction_rus
    get "/instruction_kaz", PageController, :instruction_kaz
  end

  #        ##   #####  #    # # #    #
  #       #  #  #    # ##  ## # ##   #
  #      #    # #    # # ## # # # #  #
  #      ###### #    # #    # # #  # #
  #      #    # #    # #    # # #   ##
  #      #    # #####  #    # # #    #

  scope "/admin", KursonliKursWeb.Admin do
    pipe_through [:browser, :clean]

    get "/login", AuthController, :login_form
    post "/login", AuthController, :login_form_submit
    get "/logout", AuthController, :admin_logout
  end

  scope "/admin", KursonliKursWeb.Admin do
    pipe_through [:browser, :admin_check, :admin_app]

    scope "/organization" do
      get "/", OrganizationController, :organizations_list
      post "/", OrganizationController, :create_organization
      get "/update", OrganizationController, :update_organization_status
    end

    scope "/filial" do
      get "/", FilialController, :filials_list
      post "/", FilialController, :create_filial
      get "/update_status", FilialController, :update_filial_status
      post "/update", FilialController, :update_filial
      post "/update_tariff", FilialController, :update_filial_tariff
      get "/reset_password", FilialController, :reset_password
    end

    scope "/setting" do
      get "/", SettingController, :settings_list

      scope "/currencies" do
        post "/", SettingController, :create_currency
        post "/update", SettingController, :update_currency
        get "/delete", SettingController, :delete_currency
      end

      scope "/cities" do
        post "/", SettingController, :create_city
        post "/update", SettingController, :update_city
        get "/delete", SettingController, :delete_city
      end

      scope "/tariffs" do
        post "/", SettingController, :create_tariff
        post "/update", SettingController, :update_tariff
        get "/delete", SettingController, :delete_tariff
      end

      scope "/notifications" do
        post "/update", SettingController, :update_notification
      end
    end
  end

  #       #    #  ####  #####  #    # ###### #####
  #       #    # #    # #    # #   #  #      #    #
  #       #    # #    # #    # ####   #####  #    #
  #       # ## # #    # #####  #  #   #      #####
  #       ##  ## #    # #   #  #   #  #      #   #
  #       #    #  ####  #    # #    # ###### #    #

  scope "/worker", KursonliKursWeb.Worker do
    pipe_through [:browser, :clean]

    get "/login", AuthController, :login_form
    post "/login", AuthController, :login_form_submit
    get "/logout", AuthController, :worker_logout
  end

  scope "/worker", KursonliKursWeb.Worker do
    pipe_through [:browser, :worker_check, :worker_app]

    scope "/course" do
      get "/", CourseController, :courses_list
      post "/update", CourseController, :update_course
      post "/add", CourseController, :add_course
      get "/delete", CourseController, :delete_course
    end

    scope "/setting" do
      get "/", SettingController, :settings_list
      post "/update", SettingController, :update_setting

      get "/update_pass", SettingController, :update_pass
      post "/update_pass", SettingController, :update_pass_submit

      get "/payment", SettingController, :payment

      scope "/lang" do
        get("/rus", SettingController, :select_rus)
        get("/kaz", SettingController, :select_kaz)
      end
    end

    scope "/order" do
      get "/", OrderController, :orders_list
      post "/create", OrderController, :create_order
      post "/update", OrderController, :update_order
      get "/delete", OrderController, :delete_order
    end

    scope "/trade" do
      post "/create", TradeController, :create_trade
      post "/trade", TradeController, :ajax_update_message_map

      get "/delete", TradeController, :delete_trade
    end

    scope "/chat" do
      pipe_through [:api]
      delete "/chat", TradeController, :delete_chat
      get "/chat", TradeController, :get_all_message_chat_worker_id
    end
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
