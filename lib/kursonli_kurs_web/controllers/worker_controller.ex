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
  GET /worker/courses
  """
  def courses(conn, _params) do
    course_list = Courses.all()

    conn
    |> render("worker_courses.html", course_list: course_list)
  end

  @doc """
  GET /worker/orders
  """
  def orders(conn, _params) do
    order_list = Orders.order_list()

    conn
    |> render("worker_orders.html", order_list: order_list)
  end

  @doc """
  GET /worker/create_order
  """
  def create_order(conn, _params) do
    currencies_list = Currencies.all

    conn
    |> render("worker_create_order.html", currencies_list: currencies_list)
  end

  @doc """
  POST /worker/create_order
  """
  def create_order_submit(conn, params) do
    opts = %{
      date: Timex.now(),
      number: genrate_random_str(6),
      type: :sale,
      transfer: :red,
      volume: params["volume"],
      filial_id: hd(Filials.all).id,
      worker_id: get_session(conn, :worker).id,
      course_id: hd(Courses.all).id
    } |> IO.inspect
    with {:ok, order} <- Orders.create(opts) do
      conn
      |> put_flash(:info,  "Ордер #{order.number} зарегестрирован")
      |> render("worker_orders.html")
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
end
