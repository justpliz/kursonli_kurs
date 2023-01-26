defmodule KursonliKursWeb.TariffController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)

  alias KursonliKurs.Context.{Tariffs, Organizations}

  @doc """
  POST /admin/tariffs
  """
  def create_tariff(conn, params) do
    with {:ok, _tariff} <- Tariffs.create(params) do
      conn
      |> put_flash(:info, "Новый тариф успешно создан")
      |> redirect(to: "/admin/settings")
    end
  end

  @doc """
  GET /admin/tariffs/update
  """
  def update_tariff(conn,  %{"id" => id} = params) do
    with {:ok, tariff} <- Tariffs.do_get(id: String.to_integer(id)),
         {:ok, _city} <- Tariffs.update(tariff, params) do
      conn
      |> put_flash(:info, " #{tariff.name} изменен")
      |> redirect(to: "/admin/settings")
    end
  end

  @doc """
  GET /admin/tariffs/delete
  """
  def delete_tariff(conn, %{"id" => id}) do
    # TODO count -> ensure
    with {:ok, tariff} <- Tariffs.do_get(id: id),
         count <- Organizations.count(tariff_id: id) do
      if count == 0 do
        {:ok, tariff} = Tariffs.delete(tariff)

        conn
        |> put_flash(:info, "#{tariff.name} удалён")
        |> redirect(to: "/admin/settings")
      else
        conn
        |> put_flash(:error, "#{tariff.name} используется некоторыми организациями")
        |> redirect(to: "/admin/settings")
      end
    end
  end
end
