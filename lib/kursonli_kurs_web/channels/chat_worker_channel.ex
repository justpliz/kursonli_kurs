defmodule KursonliKursWeb.ChatWorkerChannel do
  use Phoenix.Channel
  require Logger
  alias KursonliKursWeb.Endpoint
  alias KursonliKurs.EtsStorage.Chat
  alias KursonliKursWeb.GeneralHelper

  def handle_info({:after_join, _msg}, socket) do
    push(socket, "join", %{status: "connected"})
    {:noreply, socket}
  end

  def terminate(_reason, _socket) do
    :ok
  end

  def join("worker:" <> _private_subtopic, message, socket) do
    {:ok, assign(socket, :receiver, message["worker_id"])}
  end

  def handle_in("new:msg", msg, socket) do
    broadcast!(socket, "new:msg", %{user: msg["worker"], body: msg["body"], type: "text"})
    IO.inspect(msg)
    Chat.insert_message(msg["worker"]["id"], socket.assigns.receiver, msg)

    # KursonliKursWeb.OnlineChannel.click_channel( socket.assigns.receiver, %{worker_id: msg["worker"]["id"]})
    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end

  def new_event("new:event", item, map_msg) do
    compared_id = GeneralHelper.compare_workers_id(item["worker_id"], item["worker"]["id"])

    {id, _, _, _user_id, message} =
      Chat.insert_message(item["worker_id"], item["worker"]["id"], map_msg)

    KursonliKursWeb.OnlineChannel.click_channel(item["worker_id"], %{
      worker_id: item["worker"]["id"]
    })

    Endpoint.broadcast!("worker:#{compared_id}", "new:event", Map.put(message, "ets_id", id))
  end
end
