defmodule KursonliKursWeb.TradeController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)

  alias KursonliKurs.Context.{
    Trades
  }

  alias KursonliKurs.EtsStorage.Chat

  def create_trade(conn, params) do
    item_map = params["item_order"] |> Jason.decode!()

    params = params |> Map.delete("item_order") |> Map.put("item_order", item_map)

    with {:ok, item} <- Trades.create(params) do
      item = item |> PwHelper.Normalize.repo()

      KursonliKursWeb.OnlineChannel.notification(
        item_map["worker_id"],
        "Вам пришло предложение от #{item_map["worker_name"]}"
      )

      KursonliKursWeb.ChatWorkerChannel.new_event(
        "new:event",
        item_map,
        Map.merge(item, %{type: "event", type_event: "active"})
      )

      conn
      |> put_flash(:info, "Сделка успешно создана")
      |> redirect(to: "/worker/orders")
    end
  end

  def ajax_update_message_map(conn, params) do
    with item_trade <- Trades.get(id: params["id"]),
         _item_trad_up <-
           Trades.update(item_trade, %{
             status: params["type_event"]
           }),
         {:ok, item} <- Chat.update_by_id_message(params["ets_id"], params) do
      KursonliKursWeb.OnlineChannel.notification(
        params["worker_id"],
        "Вам ответили на сделку!"
      )
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
end
