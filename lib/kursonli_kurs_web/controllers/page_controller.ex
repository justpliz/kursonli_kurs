defmodule KursonliKursWeb.PageController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)

  alias KursonliKurs.Context.{Currencies, Filials, Settings, Cities, Courses}
  alias KursonliKurs.EtsStorage.ScrappedData

  @doc """
  Редирект на "Алматы" при открытии главной страницы
  """
  def redirect_almaty(conn, _params) do
    conn
    |> redirect(to: "/city?name=almaty")
  end

  @doc """
  Главная страница
  """
  def index(conn, params) do
    # "Лучшие курсы" из ETS
    scrapped_list = ScrappedData.get_all()

    with {:ok, city} <- Cities.do_get(eng_name: params["name"]) do
      # Список городов с количеством актвных филиалов
      city_list = get_count_city_with_active_filials()

      # Список коротких названий валют
      currency_list = Currencies.all() |> Enum.map(&%{short_name: &1.short_name})

      # Данные филиала(название, лого, контакты) и курсы валют
      courses_list = Courses.get_filial_by_city(city.id)

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

  @doc """
  Персональная страница филиала
  """
  def personal_page(conn, params) do
    # TODO: Пересмотреть способ определения slug/filial_id.
    filial_id = params["id"]
    slug = params["filial"]
    {:ok, setting} = if is_nil(filial_id), do: Settings.do_get(slug: slug), else: Settings.do_get(filial_id: filial_id)
    with  {:ok, filial} <- Filials.do_get(id: setting.filial_id) do
      setting = setting |> PwHelper.Normalize.repo()
      courses_list = Courses.get_courses_list_by_filial_id(filial.id)
      [x_coord, y_coord] = setting.coordinates
      city = Cities.get_city_by_filial_id(filial.id)
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

  # Список городов с количеством актвных филиалов
  def get_count_city_with_active_filials() do
    Cities.all()
    |> Enum.map(&(Map.put(&1, :count, Cities.get_count_cities(&1.id))))
    |> Enum.sort_by(& &1.count, :desc)
    |> Enum.sort_by(&(&1.name == "Алматы"), :desc)
  end

  @doc """
  Инструкция на русском языке
  """
  def instruction_rus(conn, _params) do
    conn
    |> redirect(to: "/pdfs/instruction_kurs1_rus.pdf")
  end

  @doc """
  Инструкция на казахском языке
  """
  def instruction_kaz(conn, _params) do
    conn
    |> redirect(to: "/pdfs/instruction_kurs1_kaz.pdf")
  end

  # Функция по поиску лучшего курса
  # TODO: Доделать если не перейдем на ajax-запросы
  # defp find_best_courses(courses) do
  #   courses =
  #     courses
  #     |> Enum.map(&[&1.course, &1.date, &1.filial_id])

  #   {to_delete, _} =
  #     courses
  #     |> Enum.reduce({[], []}, fn [courses, _date, _id], {to_delete, untouch} ->
  #       Enum.reduce(courses, {to_delete, untouch}, fn
  #         %{short_name: name}, {to_delete, untouch} ->
  #           if name in to_delete and name not in untouch do
  #             {List.delete(to_delete, name), [name | untouch]}
  #           else
  #             {[name | to_delete], untouch}
  #           end
  #       end)
  #     end)

  #     Enum.reduce(courses, [], fn [courses, date, id], acc ->
  #       [
  #         [
  #           Enum.reduce(courses, [], fn
  #             %{short_name: name} = course, acc ->
  #               if name in to_delete do
  #                 acc
  #               else
  #                 [course | acc]
  #               end
  #           end),
  #           date,
  #           id
  #         ]
  #         | acc
  #       ]
  #     end)
  #     |> Enum.map(fn [course, _date, id] -> course |> Enum.map(&Map.put(&1, :id, id)) end)
  # end
end
