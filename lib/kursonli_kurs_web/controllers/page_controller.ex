defmodule KursonliKursWeb.PageController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)

  alias KursonliKurs.Context.{Filials, Settings}

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def personal_page(conn, %{"id" => id}) do
    with {:ok, filial} <- Filials.do_get(id: id),
         {:ok, setting} <- Settings.do_get(filial_id: filial.id) do
          setting = setting |> PwHelper.Normalize.repo()
          courses_list = Filials.get_courses_list(filial.id)
      conn
      |> render("personal_page.html", setting: setting, courses_list: courses_list)
    end
  end
end
