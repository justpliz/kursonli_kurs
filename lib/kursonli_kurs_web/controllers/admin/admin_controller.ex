defmodule KursonliKursWeb.AdminController do
  use KursonliKursWeb, :controller
  action_fallback FallbackController

  alias KursonliKurs.Context.{Admins, Organizations}

  @doc """
  GET /admin/login
  """
  def login_form(conn, _params) do
    conn
    |> render("admin_login_form.html")
    |> halt()
  end

  @doc """
  POST /admin/login
  """
  def login_form_submit(conn, params) do
    login = params["login"]
    password = hash_str(params["password"])

    case Admins.do_get(%{login: login, password: password}) do
      {:ok, admin} ->
        conn
        |> put_session(:admin, %{id: admin.id, login: admin.login})
        |> put_flash(:info, "Добро пожаловать #{admin.login}")
        |> redirect(to: "/admin")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Невеный логин или пароль")
        |> redirect(to: "/admin/login")
    end
  end

  @doc """
  GET /admin/logout
  """
  def admin_logout(conn, _params) do
    conn
    |> delete_session(:admin)
    |> redirect(to: "/admin/login")
  end

  @doc """
  GET /admin/
  """
  def index(conn, _params) do
    conn
    |> render("index.html")
  end

  def register_org(conn, _params) do
    conn
    |> render("register_org.html")
  end

  def register_org_submit(conn, params) do
    opts = %{
      name: params["name"],
      password: hash_str(params["password"]),
      photo: params["photo"],
      admin_id: get_session(conn, :admin).id
    }

    case Organizations.create(opts) do
      {ok, _org} ->
        conn
        |> put_flash(:info, "Организация успешно добавлена")
        |> redirect(to: "/admin")

      {:error, reason} ->
        conn
        |> put_flash(:error, "Проверьте вводимые данные")
        |> redirect(to: "/admin/register_org")
    end
  end
end
