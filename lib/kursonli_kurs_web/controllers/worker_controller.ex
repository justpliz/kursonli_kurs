defmodule KursonliKursWeb.WorkerController do
  use KursonliKursWeb, :controller
  action_fallback KursonliKursWeb.FallbackController

  alias KursonliKurs.Context.{Workers}

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
    opts = %{
      first_name: params["first_name"],
      last_name: params["last_name"],
      phone: params["phone"],
      email: params["email"],
      password: hash_str(params["password"])
    }

    case Workers.do_get(opts) do
      {:ok, worker} ->
        conn
        |> put_session(:worker, %{
          id: worker.id,
          first_name: worker.first_name,
          last_name: worker.last_name,
          phone: worker.phone,
          email: worker.email
        })
        |> put_flash(:info, "Добро пожаловать #{worker.first_name}")
        |> redirect(to: "/worker")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Невеный логин или пароль")
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

    with {:ok, worker} <- Workers.do_get(%{id: id, password: old_pass}),
         {:ok, _worker} <- Workers.update(worker, %{password: new_pass}) do
      conn
      |> put_flash(:info, "Пароль успешно изменен")
      |> redirect(to: "/worker")
    end
  end
end
