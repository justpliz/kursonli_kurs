defmodule KursonliKursWeb.Worker.WorkerCourseController do
  use KursonliKursWeb, :controller

  import KursonliKursWeb.Gettext
  action_fallback KursonliKursWeb.FallbackController
  alias KursonliKursWeb.GeneralHelper
  alias KursonliKurs.EtsStorage.{Chat}

  alias KursonliKurs.Context.{
    Courses,
    Currencies,
    Filials,
    Notifications,
    FilialsCurrencies
  }

  @doc """
  GET /worker/course
  Отображение списка курсов филиала
  """
  def courses_list(conn, params) do
    # TODO переделать запрос
    session = get_session(conn, :worker)
    courses_list = Filials.get_courses_list(session.filial_id)

    # TODO доделать запрос который вытащит нужные нам валюты
    # KursonliKurs.Context.Currencies.get_not_mine_crrencies(filial_id)
    my_currencies =
      FilialsCurrencies.all(filial_id: session.filial_id)
      |> Enum.map(&Currencies.get(id: &1.currency_id))

    currencies_list = Currencies.all() -- my_currencies

    last_date = Filials.get_last_date_for_course(session.filial_id)

    last_date =
      if not is_nil(last_date), do: GeneralHelper.date_to_string_data_all(last_date), else: ""

    visible_course_status = Filials.get(id: session.filial_id).visible_course_status

    {:ok, instructions} = Notifications.do_get(name: "instructions")

    expiration =
      if params["login"] == "true", do: Notifications.check_remaining_days(session.paid_up_to)

    conn
    |> render("worker_courses.html",
      courses_list: courses_list,
      last_date: last_date,
      instructions: instructions,
      visible_course_status: visible_course_status,
      expiration: expiration,
      currencies_list: currencies_list
    )
  end

  @doc """
  POST /worker/course/update
  Обновление списка курсов филиала
  """
  def update_course(conn, params) do
    session = get_session(conn, :worker)
    change_all_filials = String.to_atom(params["change_all_filials"])
    visible_course_status = String.to_atom(params["visible_course_status"])

    # check exist courses for view courses on index.html
    visible_course_status =
      if Courses.count(filial_id: session.filial_id) == 0 do
        false
      else
        visible_course_status
      end

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
    |> redirect(to: "/worker/courses")
  end

  @doc """
  POST /worker/course/add
  Добавление в список курсов нового
  """
  # TODO добавть проверку на error
  def add_course(conn, params) do
    session = get_session(conn, :worker)

    params
    |> Map.drop(["_csrf_token"])
    |> Enum.map(fn {k, _v} ->
      currency_id = String.to_integer(k)
      FilialsCurrencies.create(%{filial_id: session.filial_id, currency_id: currency_id})

      Courses.create(%{
        date: Timex.now("Asia/Almaty"),
        currency_id: currency_id,
        filial_id: session.filial_id
      })
    end)

    conn
    |> put_flash(:info, gettext("Курсы успешно обновлены"))
    |> redirect(to: "/worker/courses")
  end

  @doc """
  POST /worker/course/add
  Удаление курса из списка курсов
  """
  def delete_course(conn, %{"id" => id} = _params) do
    session = get_session(conn, :worker)

    case Courses.count(filial_id: session.filial_id) do
      1 ->
        conn
        |> put_flash(:error, gettext("Нельзя удалить все курсы"))
        |> redirect(to: "/worker/courses")

      _any ->
        with {:ok, course} <- Courses.do_get(id: id),
             {:ok, fc} <-
               FilialsCurrencies.do_get(
                 filial_id: course.filial_id,
                 currency_id: course.currency_id
               ),
             {:ok, _course} <- Courses.delete(course),
             {:ok, _fc} <- FilialsCurrencies.delete(fc) do
          conn
          |> put_flash(:info, gettext("Курс успешно удален"))
          |> redirect(to: "/worker/courses")
        end
    end
  end

  @doc """
  check "change_all_filials"
  """
  defp update_one_course(course_id, course, filial_id, change_all_filials) do
    opts = %{
      value_for_sale: course["value_for_sale"] |> rounding_str,
      value_for_purchase: course["value_for_purchase"] |> rounding_str,
      date: Timex.now("Asia/Almaty")
    }

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

  def get_all_message_chat_worker_id(conn, params) do
    id = compare_workers_id(params["user_id"], params["worker_id"])

    json(conn, %{
      chat_messages:
        Chat.get_all_by_city(id)
        |> Enum.map(fn {x, _y, _z, _j, l} -> l |> Map.put(:ets_id, x) end)
    })
  end

end
