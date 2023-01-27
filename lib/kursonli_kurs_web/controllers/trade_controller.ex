defmodule KursonliKursWeb.TradeController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)

  alias Phoenix.Endpoint

  alias KursonliKurs.Context.{
    Trades
  }

  alias KursonliKurs.EtsStorage.Chat

  def create_trade(conn, params) do
    item_map = params["item_order"] |> Jason.decode!()

    params = params |> Map.delete("item_order") |> Map.put("item_order", item_map)

    with {:ok, item} <- Trades.create(params) do
      item = item |> PwHelper.Normalize.repo()

      KursonliKursWeb.RoomChannel.new_event(
        "new:event",
        item.item_order["filial"]["city_id"],
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
      params |> IO.inspect(label: "lib/kursonli_kurs_web/controllers/trade_controller.ex:41")

      KursonliKursWeb.OnlineChannel.notification(
        params["worker_id"],
        "ВНИМАНИЕ ВАМ ОТВЕТИЛИ НА СДЕЛКУ ПЕРЕЗАГРУЗИТЕ СТРАНИЦУ! #{params["type_event"]}"
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
