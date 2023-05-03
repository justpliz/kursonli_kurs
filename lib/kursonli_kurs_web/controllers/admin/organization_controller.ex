defmodule KursonliKursWeb.Admin.OrganizationController do
  use KursonliKursWeb, :controller
  action_fallback(FallbackController)

  alias KursonliKurs.Context.{
    Cities,
    Organizations,
    Currencies,
    Filials
  }

  @doc """
  GET /admin/organization
  Отображение списка организаций.
  """
  def organizations_list(conn, _params) do
    organization_list = Organizations.all()
    cities_list = Cities.all()
    currencies_list = Currencies.all()

    conn
    |> render("organizations_list.html",
      organization_list: organization_list,
      cities_list: cities_list,
      currencies_list: currencies_list
    )
  end

  @doc """
  POST /admin/organization
  Создание связки "организаця-филиал-сотрудник".
  """
  def create_organization(conn, params) do
    password = generate_random_str(8)

    org_opts = %{
      name: params["name"],
      iin: params["iin"],
      admin_id: get_session(conn, :admin).id
    }

    filial_opts = %{
      name: params["filial_name"],
      city_id: params["city_id"]
    }

    worker_opts = %{
      email: String.downcase(params["email"]),
      password: hash_str(password)
    }

    link = if is_nil(params["link"]), do: "filial_id", else: params["link"]

    setting_opts = %{
      slug: String.downcase(params["slug"]),
      url: String.downcase(params["url"]),
      link: link,
      address: params["address"]
    }

    with {:ok, _org} <-
           Organizations.create_org_filial_worker_setting(
             org_opts,
             filial_opts,
             worker_opts,
             setting_opts
           ) do
      conn
      |> put_flash(:info, "Организация успешно добавлена, пароль: #{password}")
      |> redirect(to: "/admin/organization")
    else
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Проверьте вводимые данные")
        |> redirect(to: "/admin/organization")
    end
  end

  @doc """
  GET /admin/organization/update
  Изменение статуса организации(архивирование/активация).
  """
  def update_organization_status(conn, %{"id" => id, "org_active_status" => status}) do
    status =
      case status do
        "active" -> "archive"
        "archive" -> "active"
      end

    with {:ok, organization} <- Organizations.do_get(id: id),
         filials <- Filials.all(organization_id: organization.id),
         {:ok, organization} <-
           Organizations.update(organization, %{org_active_status: status}),
         _filials <-
           Enum.map(filials, fn x -> Filials.update(x, %{filial_active_status: status}) end) do
      conn
      |> put_flash(:info, "Статус #{organization.name} успешно обновлен")
      |> redirect(to: "/admin/organization")
    end
  end
end
