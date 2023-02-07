defmodule KursonliKursWeb.WorkerController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)
  alias KursonliKursWeb.OnlineChannel
  alias KursonliKurs.EtsStorage.{Chat, SessionWorker}

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
    user = %{
      first_name: "",
      email: "",
      phone: ""
    }

    conn
    |> render("worker_login_form.html", user: user)
    |> halt()
  end

  @doc """
  POST /worker/login
  """
  def login_form_submit(conn, params) do
    first_name = params["first_name"]

    opts = [
      email: params["email"],
      password: hash_str(params["password"])
    ]

    case Workers.do_get(opts) do
      {:ok, worker} ->
        # TODO переделать получение города
        {:ok, filial} = Filials.do_get(id: worker.filial_id)
        {:ok, city} = Cities.do_get(id: filial.city_id)
        SessionWorker.insert(worker.id)

        if SessionWorker.check_user(worker.id) do
          OnlineChannel.leave(worker.id)
        end

        conn
        |> put_session(:worker, %{
          id: worker.id,
          first_name: first_name,
          filial_id: filial.id,
          phone: params["phone"],
          email: worker.email,
          filial_name: filial.name,
          fililal_address: filial.fililal_address,
          city: %{
            id: city.id,
            name: city.name
          }
        })
        |> put_flash(:info, "Добро пожаловать #{first_name}")
        |> redirect(to: "/worker/orders")

      {:error, :not_found} ->
        user = %{
          first_name: params["first_name"],
          email: params["email"],
          phone: params["phone"]
        }

        conn
        |> put_flash(:error, "Ввведены некорректные данные")
        |> render("worker_login_form.html", user: user)
    end
  end

  @doc """
  GET /worker/logout
  """
  def worker_logout(conn, _params) do
    session = get_session(conn, :worker)
    SessionWorker.delete_by_id(session.id)

    conn
    |> delete_session(:worker)
    |> redirect(to: "/worker/login")
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
      |> redirect(to: "/worker/orders")
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
      transfer: params["transfer"],
      limit: params["limit"],
      filial_id: session.filial_id,
      worker_id: session.id,
      course: params["course"],
      worker_name: session.first_name,
      worker_phone: session.phone,
      currency_id: params["currency_id"]
    } |> IO.inspect()

    with {:ok, order} <- Orders.create(opts) do
      conn
      |> put_flash(:info, "Ордер #{order.number} зарегистрирован ")
      |> redirect(to: "/worker/orders")
    end
  end

  @doc """
  POST /worker/update_order
  """
  def update_order(conn, params) do
    %{
      id: params["id"],
      value_for_sale: params["value_for_sale"],
      value_for_purchase: params["value_for_purchase"]
    }

    conn
    |> render("worker_courses.html")
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
    # TODO переделать запрос
    filial_id = get_session(conn, :worker).filial_id
    courses_list = Filials.get_courses_list(filial_id)

    last_date =
      Filials.get_last_date_for_course(filial_id)
      |> date_to_string_all()

    conn
    |> render("worker_courses.html", courses_list: courses_list, last_date: last_date)
  end

  @doc """
  POST /worker/update_course
  """
  def update_course(conn, params) do
    courses_list =
      params
      |> Map.delete("_csrf_token")
      |> Enum.map(fn {k, v} -> {String.split(k, "|"), v} end)
      |> Enum.reduce(%{}, fn {[id, key], value}, acc ->
        Map.put(acc, id, Map.merge(Map.get(acc, id, %{}), %{key => value}))
      end)

    # def update do

    # end
    # change_all_filials = String.to_atom(params["change_all_filials"])

    # opts = %{
    #   value_for_sale: params["value_for_sale"],
    #   value_for_purchase: params["value_for_purchase"],
    #   date: Timex.now("Asia/Almaty")
    # }
  end

  def change_all_filials(change_all_filials, conn, params) do
    case change_all_filials do
      true ->
        filial_id = get_session(conn, :worker).filial_id
        {:ok, filial} = Filials.do_get(id: filial_id)

        {:ok, course} = Courses.do_get(id: params["course_id"])

        Courses.get_all_courses_by_filial(filial.organization_id, course.currency_id)
        # |> Enum.map(fn course -> Courses.update(course, opts) end)

        conn
        |> redirect(to: "/worker/courses")

      false ->
        with {:ok, course} <- Courses.do_get(id: params["course_id"]) do
          #  {:ok, _course} <- Courses.update(course, opts) do
          conn
          |> redirect(to: "/worker/courses")
        end
    end
  end

  @doc """
  POST /worker/create_course
  """
  # TODO ненужная функция
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
  GET /worker/settings
  """
  def settings(conn, _params) do
    with {:ok, filial} <- Filials.do_get(id: get_session(conn, :worker).filial_id),
         {:ok, setting} <- Settings.do_get(filial_id: filial.id) do
      photo_path = "http://#{conn.host}:#{conn.port}/#{setting.photo}"
      logo_path = "http://#{conn.host}:#{conn.port}/#{setting.logo}"

      conn
      |> render("worker_settings.html",
        setting: setting,
        photo_path: photo_path,
        logo_path: logo_path
      )
    end
  end

  @doc """
  POST /worker/update_setting
  """
  def update_setting(conn, params) do
    logo = get_image_path(params["logo"], :logo)
    photo = get_image_path(params["photo"], :photo)

    colors = %{
      "color_currency" => params["color_currency"],
      "color_scoreboard" => params["color_scoreboard"],
      "color_qualities" => params["color_qualities"],
      "color_qualities_text" => params["color_qualities_text"]
    }

    qualities = %{
      "quality1" => params["quality1"],
      "quality2" => params["quality2"],
      "quality3" => params["quality3"]
    }

    phones = %{
      "phone_for_header" => params["phone_for_header"],
      "phone1" => params["phone1"],
      "phone2" => params["phone2"],
      "phone3" => params["phone3"]
    }

    schedule = %{
      "schedule_weekdays" => params["schedule_weekdays"],
      "schedule_saturday" => params["schedule_saturday"],
      "schedule_sunday" => params["schedule_sunday"],
      "schedule_other" => params["schedule_other"]
    }

    tags = [params["gold"], params["wholesale_rate"]]

    opts = %{
      colors: colors,
      qualities: qualities,
      phones: phones,
      email: params["email"],
      schedule: schedule,
      logo: logo,
      photo: photo,
      license: params["license"],
      subdomen: params["subdomen"],
      tags: tags
    }

    with {:ok, setting} <- Settings.do_get(filial_id: get_session(conn, :worker).filial_id),
         {:ok, _setting} <- Settings.update(setting, opts) do
      conn
      |> put_flash(:info, "Настройки обновлены")
      |> redirect(to: "/worker/settings")
    end
  end
end
