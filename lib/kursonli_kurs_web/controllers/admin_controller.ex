defmodule KursonliKursWeb.AdminController do
  use KursonliKursWeb, :controller
  action_fallback(FallbackController)

  alias KursonliKurs.Context.{
    Cities,
    Admins,
    Filials,
    Organizations,
    Currencies,
    FilialsCurrencies,
    Tariffs,
    Courses,
    Settings,
    Notifications,
    Workers
  }

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
    organization_list = Organizations.all()
    cities_list = Cities.all()
    currencies_list = Currencies.all()

    conn
    |> render("admin_index.html",
      organization_list: organization_list,
      cities_list: cities_list,
      currencies_list: currencies_list
    )
  end

  @doc """
  GET /admin/register_org_submit
  Создание связки "организаця-филиал-сотрудник"
  """
  def register_org_submit(conn, params) do
    password = generate_random_str(8)

    org_opts = %{
      name: params["name"],
      iin: params["iin"],
      admin_id: get_session(conn, :admin).id
    }

    worker_opts = %{
      email: String.downcase(params["email"]),
      password: hash_str(password)
    }

    filial_opts = %{
      name: params["filial_name"],
      city_id: params["city_id"],
      filial_address: params["filial_address"]
    }

    KursonliKurs.Repo.transaction(fn ->
      with {:ok, org} <- Organizations.create(org_opts),
           filial_opts <- Map.put(filial_opts, :organization_id, org.id),
           {:ok, _filial} <-
             Filials.create_filial_worker_setting(
               filial_opts,
               worker_opts
             ) do
        conn
        |> put_flash(:info, "Организация успешно добавлена, пароль: #{password}")
        |> redirect(to: "/admin")
      else
        {:error, _reason} ->
          conn
          |> put_flash(:error, "Проверьте вводимые данные")
          |> redirect(to: "/admin")
      end
    end)
  end

  @doc """
  GET /admin/update_org_status
  """
  def update_org_status(conn, %{"id" => id, "org_active_status" => status}) do
    status =
      case status do
        "active" -> "archive"
        "archive" -> "active"
      end

    with {:ok, organization} <- Organizations.do_get(id: id),
         filials <- Filials.all(organization_id: organization.id),
         {:ok, organization} <-
           Organizations.update(organization, %{org_active_status: status}),
         _filials <-
           Enum.map(filials, fn x -> Filials.update(x, %{filial_active_status: status}) end) do
      conn
      |> put_flash(:info, "статус #{organization.name} успешно обновлен")
      |> redirect(to: "/admin")
    end
  end

  @doc """
  GET /admin/settings
  """
  def settings(conn, _params) do
    tariff_list = Tariffs.all()
    currency_list = Currencies.all()
    cities_list = Cities.all()

    {:ok, service_access} = Notifications.do_get(name: "service_access")
    {:ok, expiration} = Notifications.do_get(name: "expiration")
    {:ok, instructions} = Notifications.do_get(name: "instructions")

    conn
    |> render("admin_settings.html",
      tariff_list: tariff_list,
      currency_list: currency_list,
      cities_list: cities_list,
      service_access: service_access,
      expiration: expiration,
      instructions: instructions
    )
  end

  def create_currency_submit(conn, params) do
    opts = %{
      name: params["name"],
      short_name: String.upcase(params["short_name"]),
      color: params["color"]
    }

    with {:ok, currencies} <- Currencies.create(opts) do
      conn
      |> put_flash(:info, "#{currencies.name} создан")
      |> redirect(to: "/admin/settings")
    end
  end

  @doc """
  GET /admin/update_currency
  """
  def update_currency(conn, %{"id" => id} = params) do
    with {:ok, currency} <- Currencies.do_get(id: String.to_integer(id)),
         {:ok, _currency} <- Currencies.update(currency, params) do
      conn
      |> put_flash(:info, "Курс #{currency.name} изменен")
      |> redirect(to: "/admin/settings")
    end
  end

  @doc """
  GET /admin/delete_currency
  """
  def delete_currency(conn, %{"id" => id}) do
    with {:ok, currency} <- Currencies.do_get(id: id),
         count <- FilialsCurrencies.count(currency_id: id) do
      if count == 0 do
        {:ok, currency} = Currencies.delete(currency)

        conn
        |> put_flash(:info, "#{currency.name} удалён")
        |> redirect(to: "/admin/settings")
      else
        conn
        |> put_flash(:error, "#{currency.name} используется некоторыми филиалами")
        |> redirect(to: "/admin/settings")
      end
    end
  end

  @doc """
  POST /admin/cities
  """
  def create_city_submit(conn, params) do
    with {:ok, city} <- Cities.create(params) do
      conn
      |> put_flash(:info, "#{city.name} создан")
      |> redirect(to: "/admin/settings")
    end
  end

  @doc """
  GET /admin/cities/delete
  """
  def delete_city(conn, %{"id" => id}) do
    with {:ok, city} <- Cities.do_get(id: id),
         {:ok, city} <- Cities.delete(city) do
      conn
      |> put_flash(:info, "#{city.name} удалён")
      |> redirect(to: "/admin/settings")
    end
  end

  @doc """
  GET /admin/cities/update
  """
  def update_city(conn, %{"id" => id} = params) do
    with {:ok, city} <- Cities.do_get(id: String.to_integer(id)),
         {:ok, _city} <- Cities.update(city, params) do
      conn
      |> put_flash(:info, "Город #{city.name} изменен")
      |> redirect(to: "/admin/settings")
    end
  end

  @doc """
  GET /admin/filials
  """
  def filials(conn, _params) do
    org_list = Organizations.all()
    cities_list = Cities.all()
    tariff_list = Tariffs.all()
    filials_list = Filials.filial_list()

    conn
    |> render("admin_filials.html",
      cities_list: cities_list,
      org_list: org_list,
      filials_list: filials_list,
      tariff_list: tariff_list
    )
  end

  @doc """
  POST /admin/filials
  """
  def create_filial_submit(conn, params) do
    password = generate_random_str(8)

    worker_opts = %{
      email: String.downcase(params["email"]),
      password: hash_str(password)
    }

    filial_opts = %{
      name: params["filial_name"],
      city_id: params["city_id"],
      filial_address: params["filial_address"],
      organization_id: params["org_id"]
    }

    KursonliKurs.Repo.transaction(fn ->
      with {:ok, _filial} <-
             Filials.create_filial_worker_setting(
               filial_opts,
               worker_opts
             ) do
        conn
        |> put_flash(:info, "Филиал успешно добавлен, пароль: #{password}")
        |> redirect(to: "/admin/filials")
      else
        {:error, _reason} ->
          conn
          |> put_flash(:error, "Проверьте вводимые данные")
          |> redirect(to: "/admin/filials")
      end
    end)
  end

  @doc """
  GET /admin/filials/reset_password
  """
  def reset_password(conn, %{"filial_id" => id}) do
    password = generate_random_str(8)

    with {:ok, worker} <- Workers.do_get(filial_id: id),
         {:ok, _worker} <- Workers.update(worker, %{password: hash_str(password)}) do
      conn
      |> put_flash(:info, "Пароль успешно сброшен, новый пароль: #{password}")
      |> redirect(to: "/admin/filials")
    end
  end

  @doc """
  GET /admin/update_filial
  """
  def update_filial(conn, %{"id" => id} = params) do
    filial_opts = %{
      name: params["filial_name"],
      city_id: params["city_id"]
    }

    setting_opts = %{
      coordinates: [params["x_coordinate"], params["y_coordinate"]],
      address_2gis: params["address_2gis"],
      firm_id: params["firm_id"]
    }

    with {:ok, filial} <- Filials.do_get(id: id),
         {:ok, fiiial} <- Filials.update(filial, filial_opts),
         {:ok, setting} <- Settings.do_get(filial_id: id),
         {:ok, _setting} <- Settings.update(setting, setting_opts) do
      conn
      |> put_flash(:info, "Парамерты #{fiiial.name} успешно изменены")
      |> redirect(to: "/admin/filials")
    end
  end

  def update_filial_status(conn, %{"id" => id, "filial_active_status" => status}) do
    status =
      case status do
        "active" -> "archive"
        "archive" -> "active"
      end

    with {:ok, filial} <- Filials.do_get(id: id),
         {:ok, filial} <- Filials.update(filial, %{filial_active_status: status}) do
      conn
      |> put_flash(:info, "статус #{filial.name} успешно обновлен")
      |> redirect(to: "/admin/filials")
    end
  end

  def update_filial_tariff(
        conn,
        %{"id" => id, "tariff_id" => tariff_id, "quantity" => quantity}
      ) do
    paid_up_to = calculate_tariff(tariff_id, quantity)

    opts = %{
      paid_up_to: paid_up_to,
      tariff_id: tariff_id
    }

    with {:ok, filial} <- Filials.do_get(id: id),
         {:ok, filial} <- Filials.update(filial, opts) do
      conn
      |> put_flash(:info, "Тариф #{filial.name} успешно обновлен")
      |> redirect(to: "/admin/filials")
    end
  end

  def update_notification(conn, %{"name" => name} = params) do
    with {:ok, notification} <- Notifications.do_get(name: name),
         {:ok, notification} <- Notifications.update(notification, params) do
      conn
      |> put_flash(:info, "Объявление #{notification.name} успешно обновлено")
      |> redirect(to: "/admin/settings")
    end
  end

  defp calculate_tariff(tariff_id, quantity) do
    quantity = if quantity != "", do: String.to_integer(quantity), else: 0
    {:ok, tariff} = Tariffs.do_get(id: tariff_id)
    Timex.shift(Timex.now("Asia/Almaty"), days: tariff.days * quantity)
  end
end
