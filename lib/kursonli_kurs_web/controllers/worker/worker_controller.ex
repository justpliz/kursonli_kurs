defmodule KursonliKursWeb.WorkerController do
  use KursonliKursWeb, :controller

  import KursonliKursWeb.Gettext
  action_fallback KursonliKursWeb.FallbackController
  alias KursonliKurs.EtsStorage.SessionWorker
  alias KursonliKursWeb.OnlineChannel

  alias KursonliKurs.Context.{
    Workers,
    Filials,
    Notifications
  }

  @doc """
  GET /worker/login
  Форма авторизации сотрудника
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
  Проверка вводимых данных при авторизации сотрудника
  """
  def login_form_submit(conn, params) do
    first_name = params["first_name"]
    phone = params["phone"]

    opts = [
      email: params["email"],
      password: hash_str(params["password"])
    ]

    case Workers.do_get(opts) do
      {:ok, worker} ->
        {:ok, filial} = Filials.do_get(id: worker.filial_id)
        Workers.update(worker, %{name: first_name})

        case filial.filial_active_status do
          :active ->
            SessionWorker.insert(worker.id)

            if SessionWorker.check_user(worker.id) do
              OnlineChannel.leave(worker.id)
            end

            conn
            |> put_session(:worker, %{
              id: worker.id,
              first_name: first_name,
              filial_id: filial.id,
              phone: phone,
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
          first_name: params["first_name"],
          email: params["email"],
          phone: params["phone"]
        }

        conn
        |> put_flash(:error, gettext("Ввведены некорректные данные"))
        |> render("worker_login_form.html", user: user)
    end
  end

  @doc """
  GET /worker/logout
  Выход из личного кабинета сотрудника
  """
  def worker_logout(conn, _params) do
    session = get_session(conn, :worker)
    SessionWorker.delete_by_id(session.id)

    conn
    |> delete_session(:worker)
    |> redirect(to: "/worker/login")
  end
end
