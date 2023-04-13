defmodule KursonliKursWeb.Admin.AdminSettingController do
  use KursonliKursWeb, :controller
  action_fallback(FallbackController)

  alias KursonliKurs.Context.{
    Cities,
    Currencies,
    FilialsCurrencies,
    Tariffs,
    Notifications,
    Filials
  }

  @doc """
  GET /admin/setting
  """
  def setting(conn, _params) do
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
      |> redirect(to: "/admin/setting")
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
      |> redirect(to: "/admin/setting")
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
        |> redirect(to: "/admin/setting")
      else
        conn
        |> put_flash(:error, "#{currency.name} используется некоторыми филиалами")
        |> redirect(to: "/admin/setting")
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
      |> redirect(to: "/admin/setting")
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
      |> redirect(to: "/admin/setting")
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
      |> redirect(to: "/admin/setting")
    end
  end

  def update_notification(conn, %{"name" => name} = params) do
    with {:ok, notification} <- Notifications.do_get(name: name),
         {:ok, notification} <- Notifications.update(notification, params) do
      conn
      |> put_flash(:info, "Объявление #{notification.name} успешно обновлено")
      |> redirect(to: "/admin/setting")
    end
  end

  @doc """
  POST /admin/tariffs
  """
  def create_tariff(conn, params) do
    with {:ok, _tariff} <- Tariffs.create(params) do
      conn
      |> put_flash(:info, gettext("Новый тариф успешно создан"))
      |> redirect(to: "/admin/setting")
    end
  end

  @doc """
  GET /admin/tariffs/update
  """
  def update_tariff(conn, %{"id" => id} = params) do
    with {:ok, tariff} <- Tariffs.do_get(id: String.to_integer(id)),
         {:ok, _city} <- Tariffs.update(tariff, params) do
      conn
      |> put_flash(:info, " #{tariff.name} #{gettext("изменен")}")
      |> redirect(to: "/admin/setting")
    end
  end

  @doc """
  GET /admin/tariffs/delete
  """
  def delete_tariff(conn, %{"id" => id}) do
    # TODO count -> ensure
    with {:ok, tariff} <- Tariffs.do_get(id: id),
         count <- Filials.count(tariff_id: id) do
      if count == 0 do
        {:ok, tariff} = Tariffs.delete(tariff)

        conn
        |> put_flash(:info, "#{gettext("Тариф")} #{tariff.name} #{gettext("удалён")}")
        |> redirect(to: "/admin/setting")
      else
        conn
        |> put_flash(:error, "#{tariff.name} #{gettext("используется некоторыми филиалами")}")
        |> redirect(to: "/admin/setting")
      end
    end
  end
end
