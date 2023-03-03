defmodule KursonliKursWeb.TradeController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)

  alias KursonliKurs.Context.{Trades}
  alias KursonliKursWeb.RoomChannel
  alias KursonliKurs.EtsStorage.Chat

  def create_trade(conn, params) do
    item_map = params["item_order"] |> Jason.decode!()

    params =
      params
      |> Map.delete("item_order")
      |> Map.put(
        "item_order",
        Map.put(item_map, "date", date_to_string_time(Timex.now("Asia/Almaty")))
      )

    with {:ok, item} <- Trades.create(params) do
      IO.inspect(item, label: "create trade")

      item =
        item
        |> PwHelper.Normalize.repo()
        |> Map.put(:worker, %{
          id: item_map["worker_id"]
        })

      KursonliKursWeb.OnlineChannel.notification(
        item_map["worker_id"],
        "Вам пришло предложение от #{item_map["worker_name"]}"
      )

      KursonliKursWeb.ChatWorkerChannel.new_event(
        "new:event",
        item_map,
        Map.merge(item, %{type: "event", type_event: "active"})
      )

      KursonliKursWeb.OnlineChannel.my_companions(
        item_map["worker_id"],
        item_map["worker"]["city"]["id"]
      )

      KursonliKursWeb.OnlineChannel.my_companions(
        item_map["worker"]["id"],
        item_map["worker"]["city"]["id"]
      )

      conn
      |> put_flash(:info, "Сделка успешно создана")
      |> redirect(to: "/worker/orders")
    end
  end

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

  def delete_trade(conn, %{"id" => id}) do
    with {:ok, trade} <- Trades.do_get(id: id),
         {:ok, _trade} <- Trades.delete(trade) do
      conn
      |> put_flash(:info, "Сделка успешно удалена")
      |> redirect(to: "/worker/orders")
    end
  end

  def delete_chat(conn, %{"id" => id}) do
    with count_delete <- Chat.delete_by_id_channel(id) do
      json(conn, %{
        status: :ok,
        count_delete: count_delete
      })
    end
  end
end
