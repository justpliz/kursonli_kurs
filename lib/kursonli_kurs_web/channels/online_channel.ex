defmodule KursonliKursWeb.OnlineChannel do
  use Phoenix.Channel
  alias KursonliKursWeb.Endpoint

  def join("online:", message, socket) do
    send(self, {:after_join, message})

    {:ok, socket}
  end

  def join("online:" <> private_subtopic, message, socket) do
    if check_user(private_subtopic) do
      send(self, {:after_join, message})

      # KursonliKurs.EtsStorage.UserOnline.insert(
      #   socket.assigns[:user]["id"],
      #   socket.assigns[:user]["city"]["id"],
      #   socket.assigns[:user]
      # )

      {:ok, socket}
    else
      {:error, %{reason: "user_not_found"}}
    end
  end

  @doc """
  # leave by user_id
  """
  def leave(user_id) do
    # KursonliKurs.EtsStorage.UserOnline.delete_online_user(user_id)

    Endpoint.broadcast!("online:#{user_id}", "leave", %{})
  end

  def handle_info({:after_join, _msg}, socket) do
    my_companions(socket.assigns[:user]["id"], socket.assigns[:user]["city"]["id"])

    {:noreply, socket}
  end

  @doc """
  # Отправляет по айди воркера сообщение
  """
  def notification(user_id, message) do
    Endpoint.broadcast!("online:#{user_id}", "notification", %{message: message})
  end

  def online() do
    map = KursonliKurs.EtsStorage.UserOnline.get_all()
    count = map |> Enum.count()

    Enum.map(map, fn x ->
      Endpoint.broadcast!("online:#{x}", "online:new", %{count: count})
    end)

    :ok
  end

  @spec change_color(any, any) :: :ok
  @doc """
  # Меняет цвет ивента
  """
  def change_color(user_id, data) do
    Endpoint.broadcast!("online:#{user_id}", "new:change_color", %{data: data})
  end

  def my_companions(user_id, city_id) do
    users = KursonliKurs.EtsStorage.Chat.get_chats_user(user_id, city_id)
    Endpoint.broadcast!("online:#{user_id}", "user:entered", %{data: users})
  end

  def click_channel(user_id, map) when is_map(map) do
    Endpoint.broadcast!("online:#{user_id}", "new:click", map)
  end

  defp check_user(worker_id) do
    KursonliKurs.Context.Workers.all()
    |> Enum.any?(fn x -> x.id == worker_id end)
  end
end
