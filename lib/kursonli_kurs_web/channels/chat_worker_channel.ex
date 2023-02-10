defmodule KursonliKursWeb.ChatWorkerChannel do
  use Phoenix.Channel
  require Logger
  alias KursonliKursWeb.Endpoint
  alias KursonliKurs.EtsStorage.{Chat}
  alias KursonliKursWeb.GeneralHelper

  def handle_info({:after_join, _msg}, socket) do
    push(socket, "join", %{status: "connected"})
    {:noreply, socket}
  end

  def terminate(_reason, _socket) do
    :ok
  end

  def join("worker:" <> _private_subtopic, message, socket) do
    IO.inspect(message)
      {:ok, assign(socket, :receiver, message["worker_id"])}

  end

  def handle_in("new:msg", msg, socket) do
    broadcast!(socket, "new:msg", %{user: msg["worker"], body: msg["body"], type: "text"})

    Chat.insert_message(msg["worker"]["id"], socket.assigns.receiver, msg)
    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end




  def new_event("new:event", item, map_msg) do
    compared_id = GeneralHelper.compare_workers_id(item["worker_id"], item["worker"]["id"])
    {id, _, _, _user_id, message} = Chat.insert_message(item["worker_id"], item["worker"]["id"], map_msg)

    Endpoint.broadcast!("worker:#{compared_id}", "new:event", Map.put(message, "ets_id", id))
  end

  # defp check_user(worker_id) do
  #   KursonliKurs.Context.Workers.all()
  #   |> Enum.any?(fn x -> x.id == worker_id end)
  # end
end
