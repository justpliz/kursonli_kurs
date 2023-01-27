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
      {:ok, socket}
    else
      {:error, %{reason: "city_not_found"}}
    end
  end

  @doc """
  # leave by user_id
  """
  def leave(user_id) do
    Endpoint.broadcast!("online:#{user_id}", "leave", %{})
  end

  defp check_user(worker_id) do
    KursonliKurs.Context.Workers.all()
    |> Enum.any?(fn x -> x.id == worker_id end)
  end
end
