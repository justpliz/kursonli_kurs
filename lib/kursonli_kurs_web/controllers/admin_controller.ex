defmodule KursonliKursWeb.AdminController do
  use KursonliKursWeb, :controller
  action_fallback FallbackController

  alias KursonliKurs.Context.{Cities, Workers, Admins, Filials, Organizations, Currencies}

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

  def view_organization(conn, _params) do
    organization_list = Organizations.all()

    conn
    |> render("admin_organizations.html", organization_list: organization_list)
  end

  @doc """
  GET /admin/register_org
  """
  def register_org(conn, _params) do
    cities_list = Cities.all()
    conn
    |> render("register_org.html", cities_list: cities_list)
  end

  @doc """
  GET /admin/register_org_submit
  """
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

    filial_opts = %{
      name: params["filial_name"],
      address: params["address"],
      city_id: params["city_id"]
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

  @doc """
  GET /admin/currencies
  """
  def currencies(conn, _params) do
    currency_list = Currencies.all()

    conn
    |> render("admin_currency.html", currency_list: currency_list)
  end

  def create_currency_submit(conn, params) do
    opts = %{
      name: params["name"],
      short_name: String.upcase(params["short_name"])
    }

    with {:ok, currencies} <- Currencies.create(opts) do
      conn
      |> put_flash(:info, "#{currencies.name} создан")
      |> redirect(to: "/admin/currencies")
    end
  end

  @doc """
  GET /admin/delete_currency
  """
  def delete_currency(conn, %{"id" => id}) do
    with {:ok, currency} <- Currencies.do_get(id: id),
         {:ok, currency} <- Currencies.delete(currency) do
      conn
      |> put_flash(:info, "#{currency.name} удалён")
      |> redirect(to: "/admin/currencies")
    end
  end

  @doc """
  GET /admin/cities
  """
  def cities(conn, _params) do
    cities_list = Cities.all()

    conn
    |> render("admin_cities.html", cities_list: cities_list)
  end

  @doc """
  POST /admin/cities
  """
  def create_city_submit(conn, params) do
    opts = %{
      name: params["name"],
      short_name: String.upcase(params["short_name"])
    }

    with {:ok, city} <- Cities.create(opts) do
      conn
      |> put_flash(:info, "#{city.name} создан")
      |> redirect(to: "/admin/cities")
    end
  end

  @doc """
  GET /admin/delete_city
  """
  def delete_city(conn, %{"id" => id}) do
    with {:ok, city} <- Cities.do_get(id: id),
         {:ok, city} <- Cities.delete(city) do
      conn
      |> put_flash(:info, "#{city.name} удалён")
      |> redirect(to: "/admin/cities")
    end
  end
end
