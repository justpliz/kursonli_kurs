defmodule KursonliKursWeb.WorkerController do
  use KursonliKursWeb, :controller

  import KursonliKursWeb.Gettext
  action_fallback KursonliKursWeb.FallbackController
  alias KursonliKursWeb.GeneralHelper
  alias KursonliKursWeb.{OnlineChannel, RoomChannel}
  alias KursonliKurs.EtsStorage.{Chat, SessionWorker}

  alias KursonliKurs.Context.{
    Workers,
    Courses,
    Currencies,
    Orders,
    Filials,
    Trades,
    Settings,
    Notifications,
    FilialsCurrencies
  }

  @doc """
  GET /worker/login
  """
  def login_form(conn, _params) do
    user = %{
      email: ""
    }

    conn
    |> render("worker_login_form.html", user: user)
    |> halt()
  end

  def get_all_message_chat_worker_id(conn, params) do
    id = compare_workers_id(params["user_id"], params["worker_id"])

    json(conn, %{
      chat_messages:
        Chat.get_all_by_city(id)
        |> Enum.map(fn {x, _y, _z, _j, l} -> l |> Map.put(:ets_id, x) end)
    })
  end

  @doc """
  POST /worker/login
  """
  def login_form_submit(conn, params) do
    opts = [
      email: params["email"],
      password: hash_str(params["password"])
    ]

    case Workers.do_get(opts) do
      {:ok, worker} ->
        {:ok, filial} = Filials.do_get(id: worker.filial_id)

        case filial.filial_active_status do
          :active ->
            SessionWorker.insert(worker.id)

            if SessionWorker.check_user(worker.id) do
              OnlineChannel.leave(worker.id)
            end

            conn
            |> put_session(:worker, %{
              id: worker.id,
              filial_id: filial.id,
              email: worker.email,
              filial_name: filial.name,
              filial_address: filial.filial_address,
              paid_up_to: filial.paid_up_to,
              city: %{
                id: filial.city_id,
                name: filial.city.name
              }
            })
            |> redirect(to: "/worker/courses?login=true")

          :archive ->
            conn
            |> put_flash(
              :error,
              gettext("Ваш филиал находится в архиве. Обратитесь к менеджеру.")
            )
            |> redirect(to: "/worker/login")
        end

      {:error, :not_found} ->
        user = %{
          email: params["email"]
        }

        conn
        |> put_flash(:error, gettext("Ввведены некорректные данные"))
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
        |> put_flash(:error, gettext("Несовпадают пароли"))
        |> redirect(to: "/worker/update_pass")

    case Workers.do_get(id: id, password: old_pass) |> IO.inspect() do
      {:error, :not_found} ->
        conn
        |> put_flash(:error, gettext("Неверный пароль"))
        |> redirect(to: "/worker/update_pass")

      {:ok, worker} ->
        Workers.update(worker, %{password: new_pass})

        conn
        |> put_flash(:info, gettext("Пароль успешно изменен"))
        |> redirect(to: "/worker/update_pass")

      _any ->
        conn
        |> put_flash(:error, gettext("Что то пошло не так. Попробуйте еще раз"))
        |> redirect(to: "/worker/update_pass")
    end
  end

  @doc """
  GET /worker/orders
  """
  def orders(conn, _params) do
    session = get_session(conn, :worker)
    city_id = session.city.id
    address = session.filial_address

    order_list_purchase = Orders.order_list(:purchase, city_id)
    order_list_sale = Orders.order_list(:sale, city_id)

    currencies_list =
      FilialsCurrencies.all(filial_id: session.filial_id)
      |> Enum.map(fn x -> Currencies.get(id: x.currency_id) end)

    message = Chat.get_all_by_city(city_id)

    my_trades =
      Orders.all(worker_id: session.id)
      |> PwHelper.Normalize.repo()
      |> Enum.sort_by(& &1.inserted_at, :desc)

    {:ok, instructions} = Notifications.do_get(name: "instructions")

    conn
    |> render("worker_orders.html",
      order_list_purchase: order_list_purchase,
      order_list_sale: order_list_sale,
      currencies_list: currencies_list,
      message: message,
      trades: Trades.get_by_id_worker(session.id),
      my_trades: my_trades,
      address: address,
      instructions: instructions
    )
  end

  # @doc """
  # GET /worker/create_order
  # """
  # def create_order(conn, _params) do
  #   session = get_session(conn, :worker)
  #   currencies_list = Currencies.all()

  #   conn
  #   |> render("worker_orders.html", currencies_list: currencies_list)
  # end

  @doc """
  POST /worker/create_order
  """
  def create_order_submit(conn, params) do
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
    }

    with {:ok, order} <- Orders.create(opts) do
      new_order = Orders.order_one(order.id, session.city.id)

      RoomChannel.order(new_order, session.city.id)

      conn
      |> put_flash(:info, gettext("Ордер успешно зарегистрирован"))
      |> redirect(to: "/worker/orders")
    end
  end

  @doc """
  POST /worker/update_order
  """
  def update_order(conn, params) do
    session = get_session(conn, :worker)

    opts = %{
      date: Timex.now("Asia/Almaty"),
      type: params["order_type"],
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
    }

    with {:ok, order} <- Orders.do_get(id: params["id"]),
         {:ok, order} <- Orders.update(order, opts),
         {:ok, order} <- Orders.do_get(id: order.id) do
      # TODO надо для того чтобы автоматически отображать при обновлении
      order =
        order
        |> Map.put(:course_sale, order.course)
        |> Map.put(:currency_short_name, order.currency.short_name)
        |> Map.put(:color, order.currency.color)

      RoomChannel.update_order(order, session.city.id)

      conn
      |> put_flash(:info, gettext("Ордер успешно обновлен"))
      |> redirect(to: "/worker/orders")
    end
  end

  @doc """
  GET /worker/delete_order
  """
  def delete_order(conn, %{"id" => id}) do
    session = get_session(conn, :worker)

    with {:ok, order} <- Orders.do_get(id: id),
         {_count, _trades} <- Trades.delete_all(order.id),
         {:ok, _order} <- Orders.delete(order) do
      RoomChannel.delete_order(order, session.city.id)

      conn
      |> put_flash(:info, gettext("Ордер удалён"))
      |> redirect(to: "/worker/orders")
    end
  end

  @doc """
  GET /worker/courses
  """
  def courses(conn, params) do
    session = get_session(conn, :worker)
    courses_list = Filials.get_courses_list(session.filial_id)

    # Список валют которых нет у филиала
    # TODO: Сделать Ecto запросом
    not_mine_currencies_list =
      Currencies.all() -- Enum.map(courses_list, &Currencies.get(id: &1.currency_id))

    # Дата последнего обновления курса
    last_update_date = find_last_date(Enum.map(courses_list, & &1.date))

    # Флаг отображения курсов филиала на основной странице
    visible_course_status = Filials.get(id: session.filial_id).visible_course_status

    {:ok, instructions} = Notifications.do_get(name: "instructions")

    expiration =
      if params["login"] == "true", do: Notifications.check_remaining_days(session.paid_up_to)

    conn
    |> render("worker_courses.html",
      courses_list: courses_list,
      last_update_date: last_update_date,
      instructions: instructions,
      visible_course_status: visible_course_status,
      expiration: expiration,
      not_mine_currencies_list: not_mine_currencies_list
    )
  end

  @doc """
  POST /worker/update_course
  """
  def update_course(conn, params) do
    session = get_session(conn, :worker)
    change_all_filials = String.to_atom(params["change_all_filials"])
    visible_course_status = String.to_atom(params["visible_course_status"])

    # check exist courses for view courses on index.html
    visible_course_status =
      if Courses.count(filial_id: session.filial_id) == 0 do
        false
      else
        visible_course_status
      end

    params
    |> Map.drop(["_csrf_token", "change_all_filials", "visible_course_status"])
    |> Enum.map(fn {k, v} -> {String.split(k, "|"), v} end)
    |> Enum.reduce(%{}, fn {[id, key], value}, acc ->
      Map.put(acc, id, Map.merge(Map.get(acc, id, %{}), %{key => value}))
    end)
    |> Enum.map(fn {id, course} ->
      update_one_course(id, course, session.filial_id, change_all_filials)
    end)

    {:ok, filial} = Filials.do_get(id: session.filial_id)
    {:ok, _filial} = Filials.update(filial, %{visible_course_status: visible_course_status})

    conn
    |> put_flash(:info, gettext("Курсы успешно обновлены"))
    |> redirect(to: "/worker/courses")
  end

  # TODO добавть проверку на error
  def new_courses(conn, params) do
    session = get_session(conn, :worker)

    params
    |> Map.drop(["_csrf_token"])
    |> Enum.map(fn {k, _v} ->
      currency_id = String.to_integer(k)
      FilialsCurrencies.create(%{filial_id: session.filial_id, currency_id: currency_id})

      Courses.create(%{
        date: Timex.now("Asia/Almaty"),
        currency_id: currency_id,
        filial_id: session.filial_id
      })
    end)

    conn
    |> put_flash(:info, gettext("Курсы успешно обновлены"))
    |> redirect(to: "/worker/courses")
  end

  def delete_course(conn, %{"id" => id} = _params) do
    session = get_session(conn, :worker)

    case Courses.count(filial_id: session.filial_id) do
      1 ->
        conn
        |> put_flash(:error, gettext("Нельзя удалить все курсы"))
        |> redirect(to: "/worker/courses")

      _any ->
        with {:ok, course} <- Courses.do_get(id: id),
             {:ok, fc} <-
               FilialsCurrencies.do_get(
                 filial_id: course.filial_id,
                 currency_id: course.currency_id
               ),
             {:ok, _course} <- Courses.delete(course),
             {:ok, _fc} <- FilialsCurrencies.delete(fc) do
          conn
          |> put_flash(:info, gettext("Курс успешно удален"))
          |> redirect(to: "/worker/courses")
        end
    end
  end

  @doc """
  check "change_all_filials"
  """
  def update_one_course(course_id, course, filial_id, change_all_filials) do
    opts = %{
      value_for_sale: course["value_for_sale"] |> rounding_str,
      value_for_purchase: course["value_for_purchase"] |> rounding_str,
      date: Timex.now("Asia/Almaty")
    }

    case change_all_filials do
      true ->
        {:ok, filial} = Filials.do_get(id: filial_id)

        {:ok, course} = Courses.do_get(id: course_id)

        Courses.get_all_courses_by_filial(filial.organization_id, course.currency_id)
        |> Enum.map(fn course -> Courses.update(course, opts) end)

      false ->
        {:ok, course} = Courses.do_get(id: course_id)
        {:ok, _course} = Courses.update(course, opts)
    end
  end

  @doc """
  GET /worker/settings
  """
  def settings(conn, _params) do
    session = get_session(conn, :worker)

    with {:ok, filial} <- Filials.do_get(id: session.filial_id),
         {:ok, setting} <- Settings.do_get(filial_id: filial.id) do
      photo_path = "http://#{conn.host}:#{conn.port}/#{setting.photo}"
      logo_path = "http://#{conn.host}:#{conn.port}/#{setting.logo}"

      {:ok, instructions} = Notifications.do_get(name: "instructions")

      conn
      |> render("worker_settings.html",
        filial: filial,
        setting: setting,
        photo_path: photo_path,
        logo_path: logo_path,
        instructions: instructions
      )
    end
  end

  @doc """
  POST /worker/update_setting
  """
  def update_setting(conn, params) do
    filial_id = get_session(conn, :worker).filial_id
    logo = get_image_path(params["logo"], :logo, filial_id)
    photo = get_image_path(params["photo"], :photo, filial_id)

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

    promo = %{
      "promo1" => params["promo1"],
      "promo2" => params["promo2"]
    }

    tags = [params["wholesale_rate"], params["gold"]]

    visible_website_status = params["visible_website_status"]

    filial_opts = %{
      name: params["filial_name"],
      filial_address: params["filial_address"]
    }

    opts = %{
      colors: colors,
      qualities: qualities,
      phones: phones,
      email: String.downcase(params["email"]),
      schedule: schedule,
      logo: logo,
      photo: photo,
      license: params["license"],
      subdomen: params["subdomen"],
      description: params["description"],
      tags: tags,
      promo: promo,
      visible_website_status: visible_website_status
    }

    with {:ok, filial} <- Filials.do_get(id: filial_id),
         {:ok, setting} <- Settings.do_get(filial_id: filial_id),
         {:ok, _fiiial} <- Filials.update(filial, filial_opts),
         {:ok, _setting} <- Settings.update(setting, opts) do
      conn
      |> put_flash(:info, gettext("Настройки обновлены"))
      |> redirect(to: "/worker/settings")
    end
  end

  def payment(conn, _params) do
    service_access = Notifications.get(name: "service_access")

    conn
    |> render("payment.html", service_access: service_access)
  end

  def select_rus(conn, params) do
    conn
    |> put_session(:lang, "rus")
    |> redirect(to: params["redirect_path"])
  end

  def select_kaz(conn, params) do
    conn
    |> put_session(:lang, "kaz")
    |> redirect(to: params["redirect_path"])
  end

  # Определение последнего обновление курса.
  # Необязательная функция, т.к. все курсы обновляются одновременно.
  defp find_last_date(date_list) do
    last_date =
      date_list
      |> Enum.sort_by(& &1, {:asc, Date})
      |> hd

    if not is_nil(last_date), do: GeneralHelper.date_to_string_data_all(last_date), else: ""
  end
end
