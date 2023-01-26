defmodule KursonliKursWeb.TradeController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)

  alias KursonliKurs.Context.{
    Trades
  }

  def create_trade(conn, params) do
    item_map = params["item_order"] |> Jason.decode!()

    params = params |> Map.delete("item_order") |> Map.put("item_order", item_map)

    with {:ok, item} <- Trades.create(params) do
      item = item |> PwHelper.Normalize.repo()

      KursonliKursWeb.RoomChannel.new_event(
        "new:event",
        item.item_order["filial"]["city_id"],
        Map.put(item, :type, "event")
      )

      conn
      |> put_flash(:info, "Сделка успешно создана")
      |> redirect(to: "/worker/orders")
    end
  end
end
