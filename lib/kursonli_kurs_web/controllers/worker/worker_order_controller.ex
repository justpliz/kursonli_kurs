defmodule KursonliKursWeb.Worker.WorkerOrderController do
  use KursonliKursWeb, :controller

  import KursonliKursWeb.Gettext
  action_fallback KursonliKursWeb.FallbackController
  alias KursonliKursWeb.{RoomChannel}
  alias KursonliKurs.EtsStorage.{Chat}

  alias KursonliKurs.Context.{
    Currencies,
    Orders,
    Notifications,
    FilialsCurrencies
  }

  @doc """
  GET /worker/orders
  """
  def orders(conn, _params) do
    session = get_session(conn, :worker)
    city_id = session.city.id
    address = session.filial_address

    order_list_purchase = Orders.order_list(:purchase, city_id)
    order_list_sale = Orders.order_list(:sale, city_id)

    currencies_list =
      FilialsCurrencies.all(filial_id: session.filial_id)
      |> Enum.map(fn x -> Currencies.get(id: x.currency_id) end)

    message = Chat.get_all_by_city(city_id)

    my_trades =
      Orders.all(worker_id: session.id)
      |> PwHelper.Normalize.repo()
      |> Enum.sort_by(& &1.inserted_at, :desc)

    {:ok, instructions} = Notifications.do_get(name: "instructions")

    conn
    |> render("worker_orders.html",
      order_list_purchase: order_list_purchase,
      order_list_sale: order_list_sale,
      currencies_list: currencies_list,
      message: message,
      trades: Trades.get_by_id_worker(session.id),
      my_trades: my_trades,
      address: address,
      instructions: instructions
    )
  end

  @doc """
  POST /worker/create_order
  """
  def create_order_submit(conn, params) do
    session = get_session(conn, :worker)

    opts = %{
      date: Timex.now("Asia/Almaty"),
      number: generate_random_str(6),
      type: params["type"],
      volume: params["volume"],
      terms: params["terms"],
      transfer: params["transfer"],
      limit: params["limit"],
      filial_id: session.filial_id,
      worker_id: session.id,
      course: params["course"],
      worker_name: session.first_name,
      worker_phone: session.phone,
      currency_id: params["currency_id"]
    }

    with {:ok, order} <- Orders.create(opts) do
      new_order = Orders.order_one(order.id, session.city.id)

      RoomChannel.order(new_order, session.city.id)

      conn
      |> put_flash(:info, gettext("Ордер успешно зарегистрирован"))
      |> redirect(to: "/worker/orders")
    end
  end

  @doc """
  POST /worker/update_order
  """
  def update_order(conn, params) do
    session = get_session(conn, :worker)

    opts = %{
      date: Timex.now("Asia/Almaty"),
      type: params["order_type"],
      volume: params["volume"],
      terms: params["terms"],
      transfer: params["transfer"],
      limit: params["limit"],
      filial_id: session.filial_id,
      worker_id: session.id,
      course: params["course"],
      worker_name: session.first_name,
      worker_phone: session.phone,
      currency_id: params["currency_id"]
    }

    with {:ok, order} <- Orders.do_get(id: params["id"]),
         {:ok, order} <- Orders.update(order, opts),
         {:ok, order} <- Orders.do_get(id: order.id) do
      # TODO надо для того чтобы автоматически отображать при обновлении
      order =
        order
        |> Map.put(:course_sale, order.course)
        |> Map.put(:currency_short_name, order.currency.short_name)
        |> Map.put(:color, order.currency.color)

      RoomChannel.update_order(order, session.city.id)

      conn
      |> put_flash(:info, gettext("Ордер успешно обновлен"))
      |> redirect(to: "/worker/orders")
    end
  end

  @doc """
  GET /worker/delete_order
  """
  def delete_order(conn, %{"id" => id}) do
    session = get_session(conn, :worker)

    with {:ok, order} <- Orders.do_get(id: id),
         {_count, _trades} <- Trades.delete_all(order.id),
         {:ok, _order} <- Orders.delete(order) do
      RoomChannel.delete_order(order, session.city.id)

      conn
      |> put_flash(:info, gettext("Ордер удалён"))
      |> redirect(to: "/worker/orders")
    end
  end
end
