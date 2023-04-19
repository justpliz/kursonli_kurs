defmodule KursonliKursWeb.PageController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)

  alias KursonliKurs.Context.{Currencies, Filials, Settings, Cities}
  alias KursonliKurs.EtsStorage.ScrappedData

  def redirect_almaty(conn, _params) do
    conn
    |> redirect(to: "/city?name=almaty")
  end

  def index(conn, params) do
    with {:ok, city} <- Cities.do_get(eng_name: params["name"]) do
      scrapped_list = ScrappedData.get_all()
      city_list = get_count_city_with_active_filials()
      currency_list = Currencies.all() |> Enum.map(&%{short_name: &1.short_name})

      courses_list = Filials.get_filial_by_city(city.id)

      conn
      |> render("index.html",
        courses_list: courses_list,
        city_list: city_list,
        name: city.name,
        currency_list: currency_list,
        scrapped_list: scrapped_list
      )
    end
  end

  def personal_page(conn, %{"filial" => id}) do
    with {:ok, filial} <- Filials.do_get(id: id),
         {:ok, setting} <- Settings.do_get(filial_id: filial.id) do
      setting = setting |> PwHelper.Normalize.repo()
      courses_list = Filials.get_courses_list_by_filial_id(filial.id)
      [x_coord, y_coord] = setting.coordinates
      city = Filials.get_city_by_filial_id(filial.id)
      photo_path = "http://#{conn.host}:#{conn.port}/#{setting.photo}"
      logo_path = "http://#{conn.host}:#{conn.port}/#{setting.logo}"

      conn
      |> render("personal_page.html",
        setting: setting,
        filial: filial,
        city_name: city.name,
        city_eng_name: city.eng_name,
        courses_list: courses_list,
        x_coord: x_coord,
        y_coord: y_coord,
        photo_path: photo_path,
        logo_path: logo_path
      )
    end
  end

  def get_count_city_with_active_filials() do
    Cities.all()
    |> Enum.map(fn city ->
      count =
        Filials.count(
          city_id: city.id,
          filial_active_status: :active,
          visible_course_status: true
        )

      %{name: city.name, count: count, eng_name: city.eng_name}
    end)
    |> Enum.sort_by(& &1.count, :desc)
    |> Enum.sort_by(&(&1.name == "Алматы"), :desc)
  end

  def instruction_rus(conn, _params) do
    conn
    |> redirect(to: "/pdfs/instruction_kurs-online_rus.pdf")
  end

  def instruction_kaz(conn, _params) do
    conn
    |> redirect(to: "/pdfs/instruction_kurs-online_kaz.pdf")
  end

  def find_best_courses(courses) do
    courses =
      courses
      # |> delete_old_courses
      |> Enum.map(&[&1.course, &1.date, &1.filial_id])

    {to_delete, _} =
      courses
      |> Enum.reduce({[], []}, fn [courses, _date, _id], {to_delete, untouch} ->
        Enum.reduce(courses, {to_delete, untouch}, fn
          %{short_name: name}, {to_delete, untouch} ->
            if name in to_delete and name not in untouch do
              {List.delete(to_delete, name), [name | untouch]}
            else
              {[name | to_delete], untouch}
            end
        end)
      end)

    courses_list =
      Enum.reduce(courses, [], fn [courses, date, id], acc ->
        [
          [
            Enum.reduce(courses, [], fn
              %{short_name: name} = course, acc ->
                if name in to_delete do
                  acc
                else
                  [course | acc]
                end
            end),
            date,
            id
          ]
          | acc
        ]
      end)
      |> Enum.map(fn [course, date, id] -> course |> Enum.map(&Map.put(&1, :id, id)) end)
  end
end
