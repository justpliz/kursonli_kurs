defmodule KursonliKursWeb.PageController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)

  alias KursonliKurs.Context.{Filials, Settings}

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def personal_page(conn, %{"id" => id} = params) do
    with {:ok, filial} <- Filials.do_get(id: id),
         {:ok, setting} <- Settings.do_get(filial_id: filial.id) do
      conn
      |> render("personal_page.html", filial: filial, setting: setting)
    end
  end
end
