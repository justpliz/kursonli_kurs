defmodule KursonliKursWeb.AdminController do
  use KursonliKursWeb, :controller
  action_fallback FallbackController

  alias KursonliKurs.Context.{Workers, Admins, Filials, Organizations}

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
    opts = %{
      login: params["login"],
      password: hash_str(params["password"])
    }

    case Admins.do_get(opts) do
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
    |> render("admin_index.html")
  end

  def register_org(conn, _params) do
    conn
    # |> put_layout("client_app.html")
    |> render("register_org.html")
  end

  def register_org_submit(conn, params) do
    password = genrate_random_pass(8)

    org_opts = %{
      name: params["name"],
      photo: params["photo"],
      iin: params["iin"],
      admin_id: get_session(conn, :admin).id
    }

    worker_opts = %{
      first_name: params["first_name"],
      last_name: params["last_name"],
      email: params["email"],
      phone: params["phone"],
      password: hash_str(password)
    }

    filial_opts = %{
      name: params["filial_name"]
    }

    with {:ok, org} <- Organizations.create(org_opts) |> IO.inspect,
         worker_opts <- Map.put(worker_opts, :organization_id, org.id),
         filial_opts <- Map.put(filial_opts, :organization_id, org.id),
         {:ok, _worker} <- Workers.create(worker_opts) |> IO.inspect,
         {:ok, _filial} <- Filials.create(filial_opts) |> IO.inspect do
      conn
      |> put_flash(:info, "Организация успешно добавлена, пароль: #{password}")
      |> redirect(to: "/admin")
    else
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Проверьте вводимые данные")
        |> redirect(to: "/admin/register_org")
    end
  end

  def register_worker(conn, _params) do
    conn
    |> render("register_org.html")
  end

  def register_worker_submit(conn, params) do
    opts = %{
      name: params["name"],
      password: hash_str(params["password"]),
      photo: params["photo"],
      admin_id: get_session(conn, :admin).id
    }

    case Organizations.create(opts) do
      {:ok, _org} ->
        conn
        |> put_flash(:info, "Организация успешно добавлена")
        |> redirect(to: "/admin")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Проверьте вводимые данные")
        |> redirect(to: "/admin/register_org")
    end
  end
end
