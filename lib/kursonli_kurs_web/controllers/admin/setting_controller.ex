defmodule KursonliKursWeb.Admin.SettingController do
  use KursonliKursWeb, :controller
  action_fallback(FallbackController)

  alias KursonliKurs.Context.{
    Cities,
    Currencies,
    Tariffs,
    Notifications
  }

  @doc """
  GET /admin/setting
  Отображение списка настроек портала(тарифы, объявления, валюты, города)
  """
  def settings_list(conn, _params) do
    tariff_list = Tariffs.all()
    currency_list = Currencies.all()
    cities_list = Cities.all()

    {:ok, service_access} = Notifications.do_get(name: "service_access")
    {:ok, expiration} = Notifications.do_get(name: "expiration")
    {:ok, instructions} = Notifications.do_get(name: "instructions")

    conn
    |> render("settings_list.html",
      tariff_list: tariff_list,
      currency_list: currency_list,
      cities_list: cities_list,
      service_access: service_access,
      expiration: expiration,
      instructions: instructions
    )
  end

  @doc """
  POST /admin/setting/currencies
  Создание новой валюты
  """
  def create_currency(conn, params) do
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
  POST /admin/setting/currencies/update
  Обновление данных(name, short_name, color) валюты
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
  GET /admin/setting/currencies/delete
  Удаление валюты если она не используется филиалами
  """
  def delete_currency(conn, %{"id" => id}) do
    case Currencies.delete(id) do
      {:ok, currency} ->
        conn
        |> put_flash(:info, "#{currency.name} удалён")
        |> redirect(to: "/admin/setting")

      {:error, currency} ->
        conn
        |> put_flash(:error, "#{currency.name} используется некоторыми филиалами")
        |> redirect(to: "/admin/setting")

      _any ->
        conn
        |> put_flash(:error, "Что то пошло не так. Попробуйте еще раз")
        |> redirect(to: "/admin/setting")
    end
  end

  @doc """
  POST /admin/setting/cities
  Создание нового города
  """
  def create_city(conn, params) do
    with {:ok, city} <- Cities.create(params) do
      conn
      |> put_flash(:info, "#{city.name} создан")
      |> redirect(to: "/admin/setting")
    end
  end

  @doc """
  POST /admin/setting/cities/update
  Обновление данных(name, short_name, eng_name) города
  """
  def update_city(conn, %{"id" => id} = params) do
    with {:ok, city} <- Cities.do_get(id: String.to_integer(id)),
         {:ok, _city} <- Cities.update(city, params) do
      conn
      |> put_flash(:info, "Город #{city.name} изменен")
      |> redirect(to: "/admin/setting")
    end
  end

  @doc """
  GET /admin/setting/cities/delete
  Удаление города если в нем не зарегестрированы филиалы
  """
  def delete_city(conn, %{"id" => id}) do
    case Cities.delete(id) do
      {:ok, city} ->
        conn
        |> put_flash(:info, "#{city.name} удалён")
        |> redirect(to: "/admin/setting")

      {:error, city} ->
        conn
        |> put_flash(:error, "#{city.name} #{gettext("используется некоторыми филиалами")}")
        |> redirect(to: "/admin/setting")

      _any ->
        conn
        |> put_flash(:error, "Что то пошло не так. Попробуйте еще раз")
        |> redirect(to: "/admin/setting")
    end
  end

  @doc """
  POST /admin/setting/tariffs
  Создание нового тарифа
  """
  def create_tariff(conn, params) do
    with {:ok, _tariff} <- Tariffs.create(params) do
      conn
      |> put_flash(:info, gettext("Новый тариф успешно создан"))
      |> redirect(to: "/admin/setting")
    end
  end

  @doc """
  POST /admin/setting/tariffs/update
  Обновление данных(name, price, days) тарифа
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
  GET /admin/setting/tariffs/delete
  Удаление тарифа если он не используется филиалами
  """
  def delete_tariff(conn, %{"id" => id}) do
    case Tariffs.delete(id) do
      {:ok, tariff} ->
        conn
        |> put_flash(:info, "#{gettext("Тариф")} #{tariff.name} #{gettext("удалён")}")
        |> redirect(to: "/admin/setting")

      {:error, tariff} ->
        conn
        |> put_flash(:error, "#{tariff.name} #{gettext("используется некоторыми филиалами")}")
        |> redirect(to: "/admin/setting")

      _any ->
        conn
        |> put_flash(:error, "Что то пошло не так. Попробуйте еще раз")
        |> redirect(to: "/admin/setting")
    end
  end

  @doc """
  POST /admin/setting/notifications/update
  Обновление данных(description, title) объявлений по name
  """
  def update_notification(conn, %{"name" => name} = params) do
    with {:ok, notification} <- Notifications.do_get(name: name),
         {:ok, notification} <- Notifications.update(notification, params) do
      conn
      |> put_flash(:info, "Объявление #{notification.name} успешно обновлено")
      |> redirect(to: "/admin/setting")
    end
  end
end
