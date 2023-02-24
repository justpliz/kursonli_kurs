defmodule KursonliKursWeb.RoomChannel do
  use Phoenix.Channel
  require Logger
  alias KursonliKursWeb.Endpoint
  alias KursonliKurs.EtsStorage.{Chat, UserOnline}

  def join("rooms:lobby", message, socket) do
    send(self, {:after_join, message})

    {:ok, socket}
  end

  def join("rooms:" <> private_subtopic, message, socket) do
    if check_city(private_subtopic) do
      UserOnline.insert(
        socket.assigns[:user]["id"],
        private_subtopic,
        socket.assigns[:user]
      )

      send(self, {:after_join, message})
      {:ok, socket}
    else
      {:error, %{reason: "city_not_found"}}
    end
  end

  # def online_event(socket) do
  #   city_id = socket.assigns[:user]["city"]["id"] |> String.to_integer
  #   IO.inspect(city_id)
  #   users = KursonliKurs.EtsStorage.Chat.get_chats_user(socket.assigns[:user]["id"],city_id )

  #   broadcast!(socket, "user:entered", %{
  #     online_users: users
  #   })
  # end

  def handle_info({:after_join, _msg}, socket) do
    # online_event(socket)

    push(socket, "join", %{status: "connected"})
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    UserOnline.delete_online_user(socket.assigns[:user]["id"])
    # online_event(socket)

    :ok
  end

  def handle_in("new:msg", msg, socket) do
    broadcast!(socket, "new:msg", %{user: msg["worker"], body: msg["body"], type: "text"})

    Chat.insert_message(msg["worker"]["city"]["id"], msg["worker"]["id"], msg)
    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end

  def notify(%{payload: %{notify: notify}, type: :ping}, city_id) do
    Endpoint.broadcast!("rooms:#{city_id}", "notify", %{notify: notify})
  end

  def order(order, city_id) do
    Endpoint.broadcast!("rooms:#{city_id}", "new:order", %{data: order |>  PwHelper.Normalize.repo()})
  end
  def new_event("new:event", city_id, map_msg) do
    {id, _, _, _user_id, message} = Chat.insert_message(map_msg[:worker_id], city_id, map_msg)

    Endpoint.broadcast!("rooms:#{city_id}", "new:event", Map.put(message, "ets_id", id))
  end

  defp check_city(city_id) do
    KursonliKurs.Context.Cities.all()
    |> Enum.any?(fn x -> x.id == city_id |> String.to_integer() end)
  end
end
