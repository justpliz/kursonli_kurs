defmodule KursonliKursWeb.Worker.WorkerOrderController do
  use KursonliKursWeb, :controller

  import KursonliKursWeb.Gettext
  action_fallback KursonliKursWeb.FallbackController
  alias KursonliKursWeb.{RoomChannel}
  alias KursonliKurs.EtsStorage.{Chat}

  alias KursonliKurs.Context.{
    Courses,
    Currencies,
    Orders,
    Notifications,
    Trades
  }

  @doc """
  GET /worker/order
  Отображение списка ордеров филиала.
  """
  def orders_list(conn, _params) do
    session = get_session(conn, :worker)
    filial_id = session.filial_id
    city_id = session.city.id
    address = session.filial_address

    # Списки ордеров филиала
    order_list_purchase = Orders.order_list(:purchase, city_id)
    order_list_sale = Orders.order_list(:sale, city_id)

    # Список валют используемых филиалом
    # TODO: Сделать Ecto запросом
    currencies_list =
      Courses.all(filial_id: filial_id)
      |> Enum.map(fn x -> Currencies.get(id: x.currency_id) end)

    # Получение чата
    message = Chat.get_all_by_city(city_id)

    # Получение списка "моих" сделок
    my_trades =
      Orders.all(worker_id: session.id)
      |> PwHelper.Normalize.repo()
      |> Enum.sort_by(& &1.inserted_at, :desc)

    {:ok, instructions} = Notifications.do_get(name: "instructions")

    conn
    |> render("orders_list.html",
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
  POST /worker/order/create
  Создание нового ордера
  """
  def create_order(conn, params) do
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
      |> redirect(to: "/worker/order")
    end
  end

  @doc """
  POST /worker/order/update
  Обновление данных ордера(валюта, курс, лимит, объем, условия, передача).
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
         {:ok, order} <- Orders.update(order, opts) do

      # Для автоматического отображения при обновлении
        order
        |> Map.put(:course_sale, order.course)
        |> Map.put(:currency_short_name, order.currency.short_name)
        |> Map.put(:color, order.currency.color)
        |> RoomChannel.update_order(session.city.id)

      conn
      |> put_flash(:info, gettext("Ордер успешно обновлен"))
      |> redirect(to: "/worker/order")
    end
  end

  @doc """
  GET /worker/order/delete
  Удаление ордера(который создал)
  """
  def delete_order(conn, %{"id" => id}) do
    session = get_session(conn, :worker)

    with {:ok, order} <- Orders.do_get(id: id),
         {_count, _trades} <- Trades.delete_all(order.id),
         {:ok, _order} <- Orders.delete(order) do
      RoomChannel.delete_order(order, session.city.id)

      conn
      |> put_flash(:info, gettext("Ордер удалён"))
      |> redirect(to: "/worker/order")
    end
  end

end
