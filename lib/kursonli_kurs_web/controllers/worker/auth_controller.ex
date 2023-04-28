defmodule KursonliKursWeb.Worker.AuthController do
  use KursonliKursWeb, :controller

  import KursonliKursWeb.Gettext
  action_fallback KursonliKursWeb.FallbackController
  alias KursonliKurs.EtsStorage.SessionWorker
  alias KursonliKursWeb.OnlineChannel

  alias KursonliKurs.Context.{
    Workers,
    Filials
  }

  @doc """
  GET /worker/login
  Форма авторизации сотрудника.
  """
  def login_form(conn, _params) do
    # дефолтные параметры заполнения формы.
    user = %{
      email: ""
    }

    conn
    |> render("login_form.html", user: user)
    |> halt()
  end

  @doc """
  POST /worker/login
  Проверка вводимых данных при авторизации сотрудника.
  """
  def login_worker_submit(conn, params) do
    opts = [
      email: String.downcase(params["email"]),
      password: hash_str(params["password"])
    ]

    # проверка существования сотрудника с параметрами - opts
    case Workers.do_get(opts) do
      {:ok, worker} ->
        filial = Filials.get_with_setting(id: worker.filial_id)
        IO.inspect(filial.setting.address, label: "KEEK")

        # проверка активного статуса филиала сотрудника
        case filial.filial_active_status do
          :active ->
            SessionWorker.insert(worker.id)

            # проверка онлайна сотрудника(worker.id)
            if SessionWorker.check_user(worker.id) do
              OnlineChannel.leave(worker.id)
            end

            conn
            |> put_session(:worker, %{
              id: worker.id,
              filial_id: filial.id,
              email: worker.email,
              filial_name: filial.name,
              address: filial.setting.address,
              paid_up_to: filial.paid_up_to,
              city: %{
                id: filial.city_id,
                name: filial.city.name
              }
            })
            |> redirect(to: "/worker/course?login=true")

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
        |> render("login_form.html", user: user)
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
