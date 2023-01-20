defmodule KursonliKursWeb.UserSocket do
  use Phoenix.Socket

  channel "rooms:*", KursonliKursWeb.RoomChannel

  transport(:websocket, Phoenix.Transports.WebSocket)
  transport(:longpoll, Phoenix.Transports.LongPoll)

  def connect(params, socket) do

    {:ok, assign(socket, :user, params["worker"])}
  end

  def id(_socket), do: nil
end
