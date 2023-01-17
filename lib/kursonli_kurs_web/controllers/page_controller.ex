defmodule KursonliKursWeb.PageController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)

  alias KursonliKurs.Context.Filials

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def personal_page(conn, params) do
    id = params["id"]
    with {:ok, filial} <- Filials.do_get(id: id) do
      conn
      |> render("personal_page.html", filial: filial)
    end

  end
end
