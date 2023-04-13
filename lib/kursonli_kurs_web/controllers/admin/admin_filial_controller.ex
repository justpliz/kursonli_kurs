defmodule KursonliKursWeb.Admin.AdminFilialController do
  use KursonliKursWeb, :controller
  action_fallback(FallbackController)

  alias KursonliKurs.Context.{
    Cities,
    Filials,
    Organizations,
    Tariffs,
    Settings,
    Workers
  }

  @doc """
  GET /admin/filials
  """
  def filials(conn, _params) do
    org_list = Organizations.all()
    cities_list = Cities.all()
    tariff_list = Tariffs.all()
    filials_list = Filials.filial_list()

    conn
    |> render("admin_filials.html",
      cities_list: cities_list,
      org_list: org_list,
      filials_list: filials_list,
      tariff_list: tariff_list
    )
  end

  @doc """
  POST /admin/filials
  """
  def create_filial_submit(conn, params) do
    password = generate_random_str(8)

    worker_opts = %{
      email: String.downcase(params["email"]),
      password: hash_str(password)
    }

    filial_opts = %{
      name: params["filial_name"],
      city_id: params["city_id"],
      filial_address: params["filial_address"],
      organization_id: params["org_id"]
    }

    KursonliKurs.Repo.transaction(fn ->
      with {:ok, _filial} <-
             Filials.create_filial_worker_setting(
               filial_opts,
               worker_opts
             ) do
        conn
        |> put_flash(:info, "Филиал успешно добавлен, пароль: #{password}")
        |> redirect(to: "/admin/filial")
      else
        {:error, _reason} ->
          conn
          |> put_flash(:error, "Проверьте вводимые данные")
          |> redirect(to: "/admin/filial")
      end
    end)
  end

  @doc """
  GET /admin/filials/reset_password
  """
  def reset_password(conn, %{"filial_id" => id}) do
    password = generate_random_str(8)

    with {:ok, worker} <- Workers.do_get(filial_id: id),
         {:ok, _worker} <- Workers.update(worker, %{password: hash_str(password)}) do
      conn
      |> put_flash(:info, "Пароль успешно сброшен, новый пароль: #{password}")
      |> redirect(to: "/admin/filial")
    end
  end

  @doc """
  GET /admin/update_filial
  """
  def update_filial(conn, %{"id" => id} = params) do
    filial_opts = %{
      name: params["filial_name"],
      city_id: params["city_id"]
    }

    setting_opts = %{
      coordinates: [params["x_coordinate"], params["y_coordinate"]],
      address_2gis: params["address_2gis"],
      firm_id: params["firm_id"]
    }

    with {:ok, filial} <- Filials.do_get(id: id),
         {:ok, fiiial} <- Filials.update(filial, filial_opts),
         {:ok, setting} <- Settings.do_get(filial_id: id),
         {:ok, _setting} <- Settings.update(setting, setting_opts) do
      conn
      |> put_flash(:info, "Парамерты #{fiiial.name} успешно изменены")
      |> redirect(to: "/admin/filial")
    end
  end

  def update_filial_status(conn, %{"id" => id, "filial_active_status" => status}) do
    status =
      case status do
        "active" -> "archive"
        "archive" -> "active"
      end

    with {:ok, filial} <- Filials.do_get(id: id),
         {:ok, filial} <- Filials.update(filial, %{filial_active_status: status}) do
      conn
      |> put_flash(:info, "статус #{filial.name} успешно обновлен")
      |> redirect(to: "/admin/filial")
    end
  end

  def update_filial_tariff(
        conn,
        %{"id" => id, "tariff_id" => tariff_id, "quantity" => quantity}
      ) do
    paid_up_to = calculate_tariff(tariff_id, quantity)

    opts = %{
      paid_up_to: paid_up_to,
      tariff_id: tariff_id
    }

    with {:ok, filial} <- Filials.do_get(id: id),
         {:ok, filial} <- Filials.update(filial, opts) do
      conn
      |> put_flash(:info, "Тариф #{filial.name} успешно обновлен")
      |> redirect(to: "/admin/filial")
    end
  end

  defp calculate_tariff(tariff_id, quantity) do
    quantity = if quantity != "", do: String.to_integer(quantity), else: 0
    {:ok, tariff} = Tariffs.do_get(id: tariff_id)
    Timex.shift(Timex.now("Asia/Almaty"), days: tariff.days * quantity)
  end
end
