defmodule KursonliKursWeb.Admin.AdminFilialController do
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
end
