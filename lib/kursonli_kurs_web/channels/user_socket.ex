defmodule KursonliKursWeb.UserSocket do
  use Phoenix.Socket

  channel "rooms:*", KursonliKursWeb.RoomChannel

  transport(:websocket, Phoenix.Transports.WebSocket)
  transport(:longpoll, Phoenix.Transports.LongPoll)

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
