defmodule KursonliKursWeb.Admin.AdminSetting do
  use KursonliKursWeb, :controller
  action_fallback(FallbackController)

  alias KursonliKurs.Context.{
    Cities,
    Currencies,
    FilialsCurrencies,
    Tariffs,
    Notifications
  }

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

  def update_notification(conn, %{"name" => name} = params) do
    with {:ok, notification} <- Notifications.do_get(name: name),
         {:ok, notification} <- Notifications.update(notification, params) do
      conn
      |> put_flash(:info, "Объявление #{notification.name} успешно обновлено")
      |> redirect(to: "/admin/settings")
    end
  end
end
