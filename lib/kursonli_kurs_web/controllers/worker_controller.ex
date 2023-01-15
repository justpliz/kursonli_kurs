defmodule KursonliKursWeb.WorkerController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)

  alias KursonliKurs.Context.{Workers, Courses, Currencies, Orders, Filials}

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
        conn
        |> put_session(:worker, %{
          id: worker.id,
          first_name: first_name,
          last_name: last_name,
          phone: worker.phone,
          email: worker.email
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
    order_list = Orders.order_list()
    currencies_list = Currencies.all()

    conn
    |> render("worker_orders.html", order_list: order_list, currencies_list: currencies_list)
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
    IO.inspect(params, label: "params")

    opts =
      %{
        date: Timex.now(),
        number: genrate_random_str(6),
        type: :sale,
        transfer: :red,
        volume: params["volume"],
        filial_id: hd(Filials.all()).id,
        worker_id: get_session(conn, :worker).id,
        course_id: hd(Courses.all()).id
      }
      |> IO.inspect(label: "opts")

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
    # TODO: переделать получение валюты
    # TODO: привязка к конкретному или нескольким филиалам
    short_name = params["currency"]
    currency_id = Enum.find(Currencies.all(), fn x -> x.short_name == short_name end).id

    opts = %{
      currency_id: currency_id,
      filial_id: hd(Filials.all()).id,
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
end
