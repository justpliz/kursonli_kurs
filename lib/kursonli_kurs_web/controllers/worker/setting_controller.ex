defmodule KursonliKursWeb.Worker.SettingController do
  use KursonliKursWeb, :controller

  import KursonliKursWeb.Gettext
  action_fallback KursonliKursWeb.FallbackController

  alias KursonliKurs.Context.{
    Workers,
    Filials,
    Settings,
    Notifications
  }

  @doc """
  GET /worker/setting
  Отображение списка настроек основной информации/личной страницы филиала.
  """
  def settings_list(conn, _params) do
    session = get_session(conn, :worker)

    with {:ok, filial} <- Filials.do_get(id: session.filial_id),
         {:ok, setting} <- Settings.do_get(filial_id: filial.id) do
      # TODO: Пересмотреть способ обращения к файлам
      photo_path = "http://#{conn.host}:#{conn.port}/#{setting.photo}"
      logo_path = "http://#{conn.host}:#{conn.port}/#{setting.logo}"

      {:ok, instructions} = Notifications.do_get(name: "instructions")

      conn
      |> render("settings_list.html",
        filial: filial,
        setting: setting,
        photo_path: photo_path,
        logo_path: logo_path,
        instructions: instructions
      )
    end
  end

  @doc """
  POST /worker/setting/update
  Обновление информации основной информации/личной страницы филиала.
  """
  def update_setting(conn, params) do
    filial_id = get_session(conn, :worker).filial_id
    logo = get_image_path(params["logo"], :logo, filial_id)
    photo = get_image_path(params["photo"], :photo, filial_id)

    colors = %{
      "color_currency" => params["color_currency"],
      "color_scoreboard" => params["color_scoreboard"],
      "color_qualities" => params["color_qualities"],
      "color_qualities_text" => params["color_qualities_text"]
    }

    qualities = %{
      "quality1" => params["quality1"],
      "quality2" => params["quality2"],
      "quality3" => params["quality3"]
    }

    phones = %{
      "phone_for_header" => params["phone_for_header"],
      "phone1" => params["phone1"],
      "phone2" => params["phone2"],
      "phone3" => params["phone3"]
    }

    promo = %{
      "promo1" => params["promo1"],
      "promo2" => params["promo2"]
    }

    tags = [params["wholesale_rate"], params["gold"]]

    visible_website_status = params["visible_website_status"]

    filial_opts = %{
      name: params["filial_name"],
      filial_address: params["filial_address"]
    }

    opts = %{
      colors: colors,
      qualities: qualities,
      phones: phones,
      email: String.downcase(params["email"]),
      logo: logo,
      photo: photo,
      license: params["license"],
      slug: params["slug"],
      description: params["description"],
      tags: tags,
      promo: promo,
      visible_website_status: visible_website_status
    }

    with {:ok, filial} <- Filials.do_get(id: filial_id),
         {:ok, setting} <- Settings.do_get(filial_id: filial_id),
         {:ok, _fiiial} <- Filials.update(filial, filial_opts),
         {:ok, _setting} <- Settings.update(setting, opts) do
      conn
      |> put_flash(:info, gettext("Настройки обновлены"))
      |> redirect(to: "/worker/setting")
    end
  end

  @doc """
  GET /worker/setting/update_pass
  Форма обновления пароля от личного кабинета сотрудника.
  """
  def update_pass(conn, _params) do
    conn
    |> render("update_pass_form.html")
  end

  @doc """
  POST /worker/setting/update_pass
  Проверка вводимых данных при смене пароля сотрудника.
  """
  def update_pass_submit(conn, params) do
    id = get_session(conn, :worker).id
    old_pass = hash_str(params["old_pass"])
    new_pass = hash_str(params["new_pass"])
    re_new_pass = hash_str(params["re_new_pass"])

    if new_pass != re_new_pass,
      do:
        conn
        |> put_flash(:error, gettext("Несовпадают пароли"))
        |> redirect(to: "/worker/setting/update_pass")

    case Workers.do_get(id: id, password: old_pass) do
      {:error, :not_found} ->
        conn
        |> put_flash(:error, gettext("Неверный пароль"))
        |> redirect(to: "/worker/setting/update_pass")

      {:ok, worker} ->
        Workers.update(worker, %{password: new_pass})

        conn
        |> put_flash(:info, gettext("Пароль успешно изменен"))
        |> redirect(to: "/worker/setting/update_pass")
    end
  end

  @doc """
  GET /worker/setting/payment
  Отображение раздела "Оплата".
  """
  def payment(conn, _params) do
    service_access = Notifications.get(name: "service_access")

    conn
    |> render("payment.html", service_access: service_access)
  end

  @doc """
  GET /worker/setting/lang/rus
  Выставление в качестве основного языка лк сотрудника - русский.
  """
  def select_rus(conn, params) do
    conn
    |> put_session(:lang, "rus")
    |> redirect(to: params["redirect_path"])
  end

  @doc """
  GET /worker/setting/lang/kaz
  Выставление в качестве основного языка лк сотрудника - казахский.
  """
  def select_kaz(conn, params) do
    conn
    |> put_session(:lang, "kaz")
    |> redirect(to: params["redirect_path"])
  end
end
