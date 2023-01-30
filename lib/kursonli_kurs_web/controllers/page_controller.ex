defmodule KursonliKursWeb.PageController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)

  alias KursonliKurs.Context.{Filials, Settings, Cities}

  def redirect_almaty(conn, _params) do
    conn
    |> redirect(to: "/city?name=Алматы")
  end

  def index(conn, params) do
    # TODO переделать запрос
    name = if not is_nil(params["name"]), do: params["name"], else: "Алматы"

    with {:ok, city} <- Cities.do_get(name: name) do
      city_list =
        Cities.all()
        |> Enum.map(fn city ->
          count = Filials.count(city_id: city.id)
          Map.put(city, :count, count)
        end)

      courses_list = Filials.get_filial_by_city(city.id)

      conn
      |> render("index.html", courses_list: courses_list, city_list: city_list)
    end
  end

  def test(conn, _params) do
    conn
    |> render("test.html")
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
