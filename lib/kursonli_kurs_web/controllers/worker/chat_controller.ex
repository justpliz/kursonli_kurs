defmodule KursonliKursWeb.Worker.ChatController do
  use KursonliKursWeb, :controller

  action_fallback KursonliKursWeb.FallbackController
  alias KursonliKursWeb.{RoomChannel}
  alias KursonliKurs.EtsStorage.{Chat}

  alias KursonliKurs.Context.{Trades}

  def ajax_update_message_map(conn, params) do
    with item_trade <- Trades.get(id: params["id"]),
         {:ok, item_trad_up} <-
           Trades.update(item_trade, %{
             status: params["type_event"]
           }),
         {:ok, item} <- Chat.update_by_id_message(params["ets_id"], params) do
      KursonliKursWeb.OnlineChannel.notification(
        params["worker_id"],
        "Вам ответили на сделку!"
      )

      RoomChannel.update_trade(item_trad_up, item_trade.item_order["filial"]["city_id"])

      KursonliKursWeb.OnlineChannel.change_color(
        params["worker_id"],
        %{type_event: params["type_event"], ets_id: params["ets_id"]}
      )

      json(conn, %{item: item})
    else
      {:error, _reason} ->
        conn
        |> put_status(403)
        |> json(%{
          status: "error",
          reason: ""
        })
    end
  end

  def delete_chat(conn, %{"id" => id, "user_id" => user_id}) do
    with _ <-
           Chat.update_is_visible_users(id, user_id) do
      json(conn, %{
        status: "ok"
      })
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
