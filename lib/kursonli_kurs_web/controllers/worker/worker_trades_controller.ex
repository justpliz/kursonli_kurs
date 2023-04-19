defmodule KursonliKursWeb.Worker.WorkerTradesController do
  use KursonliKursWeb, :controller

  import KursonliKursWeb.Gettext
  action_fallback KursonliKursWeb.FallbackController
  alias KursonliKursWeb.{RoomChannel}
  alias KursonliKurs.EtsStorage.{Chat}

  alias KursonliKurs.Context.{Trades}

  @doc """
  POST /worker/trade/create
  Создание нового ордера
  """
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
      |> put_flash(:info, gettext("Сделка успешно создана"))
      |> redirect(to: "/worker/orders")
    end
  end



  def delete_trade(conn, %{"id" => id}) do
    with {:ok, trade} <- Trades.do_get(id: id),
         {:ok, _trade} <- Trades.delete(trade) do
      conn
      |> put_flash(:info, gettext("Сделка успешно удалена"))
      |> redirect(to: "/worker/orders")
    end
  end


end
