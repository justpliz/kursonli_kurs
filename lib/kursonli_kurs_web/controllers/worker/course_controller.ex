defmodule KursonliKursWeb.Worker.CourseController do
  use KursonliKursWeb, :controller

  import KursonliKursWeb.Gettext
  action_fallback KursonliKursWeb.FallbackController
  alias KursonliKursWeb.GeneralHelper

  alias KursonliKurs.Context.{
    Courses,
    Currencies,
    Filials,
    Notifications
  }

  @doc """
  GET /worker/course
  Отображение списка курсов филиала.
  """
  def courses_list(conn, params) do
    session = get_session(conn, :worker)
    courses_list = Courses.get_courses_list_by_filial_id(session.filial_id) |> IO.inspect()

    # Список валют которых нет у филиала
    # TODO: Сделать Ecto запросом
    not_mine_currencies_list =
      Currencies.all() -- Enum.map(courses_list, &Currencies.get(id: &1.currency_id))

    # Дата последнего обновления курса
    last_update_date = find_last_date(Enum.map(courses_list, & &1.date))

    # Флаг отображения курсов филиала на основной странице
    visible_course_status = Filials.get(id: session.filial_id).visible_course_status

    {:ok, instructions} = Notifications.do_get(name: "instructions")

    # Проверка необходимости отображения объявления о скором окончании тарифа
    expiration =
      if params["login"] == "true", do: Notifications.check_remaining_days(session.paid_up_to)

    conn
    |> render("courses_list.html",
      courses_list: courses_list,
      last_update_date: last_update_date,
      instructions: instructions,
      visible_course_status: visible_course_status,
      expiration: expiration,
      not_mine_currencies_list: not_mine_currencies_list
    )
  end

  @doc """
  POST /worker/course/update
  Обновление списка курсов филиала.
  """
  def update_course(conn, params) do
    session = get_session(conn, :worker)
    change_all_filials = String.to_atom(params["change_all_filials"])
    visible_course_status = String.to_atom(params["visible_course_status"])

    # check exist courses for view courses on index.html.
    # Запрещает показывать филиал на главной если у него нет курсов.
    visible_course_status =
      if Courses.count(filial_id: session.filial_id) == 0 do
        false
      else
        visible_course_status
      end

    # Обновление курсов филиала
    # TODO: Переделать функцию(сложно читать)
    params
    |> Map.drop(["_csrf_token", "change_all_filials", "visible_course_status"])
    |> Enum.map(fn {k, v} -> {String.split(k, "|"), v} end)
    |> Enum.reduce(%{}, fn {[id, key], value}, acc ->
      Map.put(acc, id, Map.merge(Map.get(acc, id, %{}), %{key => value}))
    end)
    |> Enum.map(fn {id, course} ->
      update_one_course(id, course, session.filial_id, change_all_filials)
    end)

    {:ok, filial} = Filials.do_get(id: session.filial_id)
    {:ok, _filial} = Filials.update(filial, %{visible_course_status: visible_course_status})

    conn
    |> put_flash(:info, gettext("Курсы успешно обновлены"))
    |> redirect(to: "/worker/course")
  end

  @doc """
  POST /worker/course/add
  Добавление в список курсов новых валют.
  """
  def add_course(conn, params) do
    session = get_session(conn, :worker)

    params
    |> Map.drop(["_csrf_token"])
    |> Enum.map(fn {k, _v} ->
      currency_id = String.to_integer(k)

      Courses.create(%{
        date: Timex.now("Asia/Almaty"),
        currency_id: currency_id,
        filial_id: session.filial_id
      })
    end)

    conn
    |> put_flash(:info, gettext("Курсы успешно обновлены"))
    |> redirect(to: "/worker/course")
  end

  @doc """
  GET /worker/course/delete
  Удаление валюты из списка курсов.
  """
  def delete_course(conn, %{"id" => id} = _params) do
    session = get_session(conn, :worker)

    # Проверка на наличие хотя бы одного курса.
    # Чтобы было нормальное отображение на главной странице.
    case Courses.count(filial_id: session.filial_id) do
      1 ->
        conn
        |> put_flash(:error, gettext("Нельзя удалить все курсы"))
        |> redirect(to: "/worker/course")

      _any ->
        with {:ok, course} <- Courses.do_get(id: id),
             {:ok, _course} <- Courses.delete(course) do
          conn
          |> put_flash(:info, gettext("Курс успешно удален"))
          |> redirect(to: "/worker/course")
        end
    end
  end

  # Обновление курсов одного филиала
  defp update_one_course(course_id, course, filial_id, change_all_filials) do
    opts = %{
      sale: course["sale"] |> rounding_str,
      buy: course["buy"] |> rounding_str,
      date: Timex.now("Asia/Almaty")
    }

    # Проверка на наличлие флага "Изменить курсы у всех филиалов"
    case change_all_filials do
      true ->
        {:ok, filial} = Filials.do_get(id: filial_id)

        {:ok, course} = Courses.do_get(id: course_id)

        Courses.get_all_courses_by_filial(filial.organization_id, course.currency_id)
        |> Enum.map(fn course -> Courses.update(course, opts) end)

      false ->
        {:ok, course} = Courses.do_get(id: course_id)
        {:ok, _course} = Courses.update(course, opts)
    end
  end

  # Определение времени последнего обновления курса.
  # Необязательная функция, т.к. все курсы обновляются одновременно?
  defp find_last_date(date_list) do
    last_date =
      date_list
      |> Enum.sort_by(& &1, {:asc, Date})
      |> hd

    if not is_nil(last_date), do: GeneralHelper.date_to_string_data_all(last_date), else: ""
  end
end
