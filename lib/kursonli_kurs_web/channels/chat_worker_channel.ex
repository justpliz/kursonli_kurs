defmodule KursonliKursWeb.ChatWorkerChannel do
  use Phoenix.Channel
  require Logger
  alias KursonliKursWeb.Endpoint
  alias KursonliKurs.EtsStorage.{Chat}

  def handle_info({:after_join, _msg}, socket) do
    push(socket, "join", %{status: "connected"})
    {:noreply, socket}
  end

  def terminate(_reason, _socket) do
    :ok
  end

  def join("worker:" <> private_subtopic, _message, socket) do
    if check_user(private_subtopic) do
      {:ok, assign(socket, :receiver,private_subtopic)}
    else
      {:error, %{reason: "city_not_found"}}
    end
  end

  def handle_in("new:msg", msg, socket) do
    broadcast!(socket, "new:msg", %{user: msg["worker"], body: msg["body"], type: "text"})

    Chat.insert_message(msg["worker"]["id"], socket.assigns.receiver, msg)
    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end

  def notify(%{payload: %{notify: notify}, type: :ping}, city_id) do
    Endpoint.broadcast!("rooms:#{city_id}", "notify", %{notify: notify})
  end

  def new_event("new:event", city_id, map_msg) do
    {id, _, _, _user_id, message} = Chat.insert_message(map_msg[:worker_id], city_id, map_msg)

    Endpoint.broadcast!("rooms:#{city_id}", "new:event", Map.put(message, "ets_id", id))
  end

  defp check_user(worker_id) do
    KursonliKurs.Context.Workers.all()
    |> Enum.any?(fn x -> x.id == worker_id end)
  end
end
