defmodule KursonliKursWeb.AdminController do
  use KursonliKursWeb, :controller
  action_fallback FallbackController

  alias KursonliKurs.Context.{Cities, Workers, Admins, Filials, Organizations, Currencies, FilialsCurrencies}

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

  @doc """
  GET /admin/organizations
  """
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
    currencies_list = Currencies.all()

    conn
    |> render("register_org.html", cities_list: cities_list, currencies_list: currencies_list)
  end

  @doc """
  GET /admin/register_org_submit
  """
  def register_org_submit(conn, params) do
    password = generate_random_str(8)
    currencies_list = params["currency"]

    org_opts =
      %{
        name: params["name"],
        iin: params["iin"],
        admin_id: get_session(conn, :admin).id
      }
      |> IO.inspect(label: "ORG")

    worker_opts =
      %{
        email: params["email"],
        phone: params["phone"],
        password: hash_str(password)
      }
      |> IO.inspect(label: "WORKER")

    filial_opts =
      %{
        name: params["filial_name"],
        city_id: params["city_id"]
      }
      |> IO.inspect(label: "FILIAL")

    with {:ok, org} <- Organizations.create(org_opts),
         filial_opts <- Map.put(filial_opts, :organization_id, org.id) |> IO.inspect(label: "LOL"),
         {:ok, filial} <- Filials.create(filial_opts) |> IO.inspect(label: "KEK"),
         worker_opts <- Map.put(worker_opts, :filial_id, filial.id) |> IO.inspect(label: "LOL1"),
         Enum.map(currencies_list, fn x-> FilialsCurrencies.create(%{currency_id: x, filial_id: filial.id}) end) |> IO.inspect(label: "KEK1"),
         {:ok, _worker} <- Workers.create(worker_opts) |> IO.inspect(label: "KEK2") do
      conn
      |> put_flash(:always, "Организация успешно добавлена, пароль: #{password}")
      |> redirect(to: "/admin")
    else
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Проверьте вводимые данные")
        |> redirect(to: "/admin/register_org")
    end
  end

  @doc """
  GET /admin/delete_organization
  """
  def delete_organization(conn, %{"id" => id}) do
    with {:ok, organization} <- Organizations.do_get(id: id),
         {:ok, organization} <- Organizations.delete(organization) do
      conn
      |> put_flash(:info, "#{organization.name} удалён")
      |> redirect(to: "/admin/organizations")
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
