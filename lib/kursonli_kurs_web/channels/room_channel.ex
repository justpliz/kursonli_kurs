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

  def online_event(socket) do
    city_id = socket.assigns[:user]["city"]["id"]

    users =
      UserOnline.get_online_users(city_id)
      |> Enum.map(fn {_id, _, _, user_map} = item -> user_map end)

    broadcast!(socket, "user:entered", %{
      online_users: users
    })
  end

  def handle_info({:after_join, msg}, socket) do
    online_event(socket)
    push(socket, "join", %{status: "connected"})
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  # def handle_info(:ping, socket) do
  #   push(socket, "new:msg", %{user: "SYSTEM", body: "ping"})
  #   {:noreply, socket}
  # end

  def terminate(reason, socket) do
    UserOnline.delete_online_user(socket.assigns[:user]["id"])
    online_event(socket)
    Logger.debug("> leave #{inspect(reason)}")
    :ok
  end

  def handle_in("new:msg", msg, socket) do
    broadcast!(socket, "new:msg", %{user: msg["worker"], body: msg["body"], type: "text"})

    Chat.insert_message(msg["worker"]["id"], msg["worker"]["city"]["id"], msg)
    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end

  def notify(%{payload: %{notify: notify}, type: :ping}, city_id) do
    Endpoint.broadcast!("rooms:#{city_id}", "notify", %{notify: notify})
  end

  def new_event("new:event", city_id, map_msg) do
    Chat.insert_message(map_msg[:worker_id], city_id, map_msg)
    Endpoint.broadcast!("rooms:#{city_id}", "new:event", map_msg)
  end

  defp check_city(city_id) do
    KursonliKurs.Context.Cities.all()
    |> Enum.any?(fn x -> x.id == city_id |> String.to_integer() end)
  end
end
