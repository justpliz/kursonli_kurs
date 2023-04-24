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

  scope "/admin", KursonliKursWeb do
    pipe_through [:browser, :clean]

    get "/login", AdminController, :login_form
    post "/login", AdminController, :login_form_submit
    get "/logout", AdminController, :admin_logout
  end

  scope "/admin", KursonliKursWeb.Admin do
    pipe_through [:browser, :admin_check, :admin_app]

    scope "/organization" do
      get "/", AdminOrganizationController, :organizations_list
      post "/", AdminOrganizationController, :create_organization
      get "/update", AdminOrganizationController, :update_organization_status
    end

    scope "/filial" do
      get "/", AdminFilialController, :filials_list
      post "/", AdminFilialController, :create_filial
      get "/update_status", AdminFilialController, :update_filial_status
      post "/update", AdminFilialController, :update_filial
      post "/update_tariff", AdminFilialController, :update_filial_tariff
      get "/reset_password", AdminFilialController, :reset_password
    end

    scope "/setting" do
      get "/", AdminSettingController, :settings_list

      scope "/currencies" do
        post "/", AdminSettingController, :create_currency
        post "/update", AdminSettingController, :update_currency
        get "/delete", AdminSettingController, :delete_currency
      end

      scope "/cities" do
        post "/", AdminSettingController, :create_city
        post "/update", AdminSettingController, :update_city
        get "/delete", AdminSettingController, :delete_city
      end

      scope "/tariffs" do
        post "/", AdminSettingController, :create_tariff
        post "/update", AdminSettingController, :update_tariff
        get "/delete", AdminSettingController, :delete_tariff
      end

      scope "/notifications" do
        post "/update", AdminSettingController, :update_notification
      end
    end
  end

  #       #    #  ####  #####  #    # ###### #####
  #       #    # #    # #    # #   #  #      #    #
  #       #    # #    # #    # ####   #####  #    #
  #       # ## # #    # #####  #  #   #      #####
  #       ##  ## #    # #   #  #   #  #      #   #
  #       #    #  ####  #    # #    # ###### #    #

  scope "/worker", KursonliKursWeb do
    pipe_through [:browser, :clean]

    get "/login", WorkerController, :login_form
    post "/login", WorkerController, :login_form_submit
    get "/logout", WorkerController, :worker_logout
  end

  scope "/worker", KursonliKursWeb.Worker do
    pipe_through [:browser, :worker_check, :worker_app]

    scope "/course" do
      get "/", WorkerCourseController, :courses_list
      post "/update", WorkerCourseController, :update_course
      post "/add", WorkerCourseController, :add_course
      get "/delete", WorkerCourseController, :delete_course
    end

    scope "/setting" do
      get "/", WorkerSettingController, :settings_list
      post "/update", WorkerSettingController, :update_setting

      get "/update_pass", WorkerSettingController, :update_pass
      post "/update_pass", WorkerSettingController, :update_pass_submit

      get "/payment", WorkerSettingController, :payment

      scope "/lang" do
        get("/rus", WorkerSettingController, :select_rus)
        get("/kaz", WorkerSettingController, :select_kaz)
      end
    end

    scope "/order" do
      get "/", WorkerOrderController, :orders_list
      post "/create", WorkerOrderController, :create_order
      post "/update", WorkerOrderController, :update_order
      get "/delete", WorkerOrderController, :delete_order
    end

    scope "/trade" do
      post "/create", WorkerTradesController, :create_trade
      post "/trade", WorkerTradesController, :ajax_update_message_map

      get "/delete", WorkerTradesController, :delete_trade
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
