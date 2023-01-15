defmodule KursonliKursWeb.AdminController do
  use KursonliKursWeb, :controller
  action_fallback FallbackController

  alias KursonliKurs.Context.Cities
  alias KursonliKurs.Context.{Workers, Admins, Filials, Organizations, Currencies}

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
    opts = [
      login: params["login"],
      password: hash_str(params["password"])
    ]

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
    password = genrate_random_str(8)

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

    {:ok, city} = Cities.do_get(name: params["city_name"])

    filial_opts = %{
      name: params["filial_name"],
      address: params["address"],
      city_id: city.id
    }

    with {:ok, org} <- Organizations.create(org_opts),
         worker_opts <- Map.put(worker_opts, :organization_id, org.id),
         filial_opts <- Map.put(filial_opts, :organization_id, org.id),
         {:ok, _worker} <- Workers.create(worker_opts),
         {:ok, _filial} <- Filials.create(filial_opts) do
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

  def create_course(conn, _params) do
    conn
    |> render("admin_currency.html")
  end

  def currency_view(conn, _params) do
    currency_list = Currencies.all()

    conn
    |> render("admin_currency.html", currency_list: currency_list)
  end

  def create_currency_submit(conn, params) do
    opts =
      %{
        short_name: params["short_name"],
        name: params["name"],
      }

    with {:ok, currencies} <- Currencies.create(opts) do
      conn
      |> put_flash(:info, "Курс #{currencies.name} создан")
      |> redirect(to: "/admin/currencies")
    end
  end

  def delete_currency(conn, %{"id" => id}) do
    with {:ok, currency} <- Currencies.do_get(id: id),
         {:ok, currency} <- Currencies.delete(currency) do
      conn
      |> put_flash(:info, "Курс #{currency.name} удалён")
      |> redirect(to: "/admin/currencies")
    end
  end
end
