defmodule KursonliKursWeb.PageController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)

  alias KursonliKurs.Context.{Filials, Settings}

  def index(conn, _params) do
    courses_list = Filials.get_courses_list("8201ed61-ea34-4ee4-a004-0b413957a146")
    conn
    |> render("index.html", courses_list: courses_list)
  end

  def personal_page(conn, %{"id" => id}) do
    with {:ok, filial} <- Filials.do_get(id: id),
         {:ok, setting} <- Settings.do_get(filial_id: filial.id) do
      setting = setting |> PwHelper.Normalize.repo()
      courses_list = Filials.get_courses_list(filial.id)
      # TODO переделать коорды
      [x_coord, y_coord] = setting.coordinates
      city = Filials.get_city_by_filial_id(filial.id)
      photo_path = "http://#{conn.host}:#{conn.port}/#{setting.photo}"
      logo_path = "http://#{conn.host}:#{conn.port}/#{setting.logo}"

      conn
      |> render("personal_page.html",
        setting: setting,
        filial: filial,
        city: city,
        courses_list: courses_list,
        x_coord: x_coord,
        y_coord: y_coord,
        photo_path: photo_path,
        logo_path: logo_path
      )
    end
  end
end
