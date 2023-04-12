defmodule KursonliKursWeb.Admin.AdminSetting do
  use KursonliKursWeb, :controller
  action_fallback(FallbackController)

  alias KursonliKurs.Context.{
    Cities,
    Filials,
    Organizations,
    Currencies,
    FilialsCurrencies,
    Tariffs,
    Settings,
    Notifications,
    Workers
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
end
