defmodule KursonliKursWeb.WorkerController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)
  alias KursonliKurs.EtsStorage.Chat

  alias KursonliKurs.Context.{
    Workers,
    Courses,
    Currencies,
    Orders,
    Filials,
    Cities,
    Trades,
    Settings
  }

  @doc """
  GET /worker/login
  """
  def login_form(conn, _params) do
    conn
    |> render("worker_login_form.html")
    |> halt()
  end

  @doc """
  POST /worker/login
  """
  def login_form_submit(conn, params) do
    first_name = params["first_name"]
    last_name = params["last_name"]

    opts = [
      phone: params["phone"],
      email: params["email"],
      password: hash_str(params["password"])
    ]

    case Workers.do_get(opts) do
      {:ok, worker} ->
        # TODO переделать получение города
        {:ok, filial} = Filials.do_get(id: worker.filial_id)
        {:ok, city} = Cities.do_get(id: filial.city_id)

        conn
        |> put_session(:worker, %{
          id: worker.id,
          first_name: first_name,
          filial_id: filial.id,
          last_name: last_name,
          phone: worker.phone,
          email: worker.email,
          city: %{
            id: city.id,
            name: city.name
          }
        })
        |> put_flash(:info, "Добро пожаловать #{first_name}")
        |> redirect(to: "/worker")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Ввведены некорректные данные")
        |> redirect(to: "/worker/login")
    end
  end

  @doc """
  GET /worker/logout
  """
  def worker_logout(conn, _params) do
    conn
    |> delete_session(:worker)
    |> redirect(to: "/worker/login")
  end

  @doc """
  GET /worker/
  """
  def index(conn, _params) do
    conn
    |> render("worker_index.html")
  end

  @doc """
  GET /worker/update_pass
  """
  def update_pass(conn, _params) do
    conn
    |> render("worker_update_pass.html")
  end

  @doc """
  POST /worker/update_pass
  """
  def update_pass_submit(conn, params) do
    id = get_session(conn, :worker).id
    old_pass = hash_str(params["old_pass"])
    new_pass = hash_str(params["new_pass"])
    re_new_pass = hash_str(params["re_new_pass"])

    if new_pass != re_new_pass,
      do:
        conn
        |> put_flash(:error, "Несовпадают пароли")
        |> redirect(to: "/worker/update_pass")

    with {:ok, worker} <- Workers.do_get(id: id, password: old_pass),
         {:ok, _worker} <- Workers.update(worker, %{password: new_pass}) do
      conn
      |> put_flash(:info, "Пароль успешно изменен")
      |> redirect(to: "/worker")
    end
  end

  @doc """
  GET /worker/orders
  """
  def orders(conn, _params) do
    order_list_purshare = Orders.order_list(:purchase)
    order_list_sale = Orders.order_list(:sale)
    city_id = get_session(conn, :worker).city.id
    worker = get_session(conn, :worker)
    currencies_list = Currencies.all()
    message = Chat.get_all_by_city(city_id)

    conn
    |> render("worker_orders.html",
      order_list_purshare: order_list_purshare,
      order_list_sale: order_list_sale,
      currencies_list: currencies_list,
      message: message,
      trades: Trades.get_by_id_worker(worker.id)
    )
  end

  @doc """
  GET /worker/create_order
  """
  def create_order(conn, _params) do
    currencies_list = Currencies.all()

    conn
    |> render("worker_orders.html", currencies_list: currencies_list)
  end

  @doc """
  POST /worker/create_order
  """
  def create_order_submit(conn, params) do
    # TODO Переделать event_info
    session = get_session(conn, :worker)

    opts = %{
      date: Timex.now("Asia/Almaty"),
      number: generate_random_str(6),
      type: params["type"],
      volume: params["volume"],
      terms: params["terms"],
      transfer: :red,
      limit: params["limit"],
      filial_id: session.filial_id,
      worker_id: session.id,
      course: params["course"],
      currency_id: params["currency_id"]
    }

    with {:ok, order} <- Orders.create(opts) do
      conn
      |> put_flash(:info, "Ордер #{order.number} зарегестрирован")
      |> redirect(to: "/worker/orders")
    end
  end

  @doc """
  POST /worker/update_course
  """
  def update_course(%{method: "POST"} = conn, params) do
    %{
      id: params["id"],
      value_for_sale: params["value_for_sale"],
      value_for_purchase: params["value_for_purchase"]
    }

    conn
    # |> render("worker_courses.html", course_list: course_list)
  end

  @doc """
  GET /worker/delete_order
  """
  def delete_order(conn, %{"id" => id}) do
    with {:ok, order} <- Orders.do_get(id: id),
         {:ok, _order} <- Orders.delete(order) do
      conn
      |> put_flash(:info, "Ордер удалён")
      |> redirect(to: "/worker/orders")
    end
  end

  @doc """
  GET /worker/courses
  """
  def courses(conn, _params) do
    courses_list = Courses.all()
    currencies_list = Currencies.all()

    conn
    |> render("worker_courses.html", courses_list: courses_list, currencies_list: currencies_list)
  end

  @doc """
  POST /worker/create_course
  """
  def create_course_submit(conn, params) do
    opts = %{
      currency_id: params["currency_id"],
      filial_id: get_session(conn, :worker).filial_id,
      value_for_sale: params["value_for_sale"],
      value_for_purchase: params["value_for_purchase"]
    }

    with {:ok, _course} <- Courses.create(opts) do
      conn
      |> put_flash(:info, "Новый курс успешно создан")
      |> redirect(to: "/worker/courses")
    end
  end

  @doc """
  GET /worker/delete_course
  """
  def delete_course(conn, %{"id" => id}) do
    with {:ok, courses} <- Courses.do_get(id: id),
         {:ok, _course} <- Courses.delete(courses) do
      # тут эта темка тоже не отрабатывает, и карренски не удаляется из таблицы
      #  {:ok, currency} <- Currencies.do_get(id: id),
      #  {:ok, _currency} <- Currencies.delete(currency) do
      conn
      |> put_flash(:info, "Курс удалён")
      |> redirect(to: "/worker/courses")
    end
  end

  @doc """
  GET /worker/settings
  """
  def settings(conn, _params) do
    with {:ok, filial} <- Filials.do_get(id: get_session(conn, :worker).filial_id),
         {:ok, setting} <- Settings.do_get(filial_id: filial.id) do
      conn
      |> render("worker_settings.html", setting: setting)
    end
  end

  @doc """
  POST /worker/update_setting
  """
  def update_setting(conn, params) do
    logo = parse_image(params["logo"])
    photo = parse_image(params["photo"])

    colors = %{
      "color_currency" => params["color_currency"],
      "colors_scoreboard" => params["colors_scoreboard"],
      "color_qualities" => params["color_qualities"],
      "color_qualities_text" => params["color_qualities_text"]
    }

    qualities = %{
      "quality1" => params["quality1"],
      "quality2" => params["quality2"],
      "quality3" => params["quality3"]
    }

    phones = %{
      "phone1" => params["phone1"],
      "phone2" => params["phone2"],
      "phone3" => params["phone3"],
    }

    schedule = %{
      "schedule_weekdays" => params["schedule_weekdays"],
      "schedule_saturday" => params["schedule_saturday"],
      "schedule_sunday" => params["schedule_sunday"],
      "schedule_other" => params["schedule_other"]
    }

    opts = %{
      colors: colors,
      qualities: qualities,
      phones: phones,
      email: params["email"],
      schedule: schedule,
      logo: logo,
      photo: photo,
      subdomen: params["subdomen"]
    }

    with {:ok, setting} <- Settings.do_get(filial_id: get_session(conn, :worker).filial_id),
         {:ok, _setting} <- Settings.update(setting, opts) do
      conn
      |> put_flash(:info, "Настройки обновлены")
      |> redirect(to: "/worker/settings")
    end
  end
end
