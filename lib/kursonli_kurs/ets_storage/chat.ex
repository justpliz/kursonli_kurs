defmodule KursonliKurs.EtsStorage.Chat do
  require Logger
  import Ex2ms

  def init(_) do
    {:ok, []}
  end

  # Запускает БД
  def start_link(state \\ []) do
    create()
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def create() do
    :dets.open_file(:chat, type: :set)
    |> case do
      {:ok, _table} -> nil
      {:error, _table} -> Logger.error("CHAT ETS NO INSTALL")
    end
  end

  def insert_message(user_id, city_id, message_map) do
    :dets.insert_new(
      :chat,
      {Ecto.UUID.generate(), city_id, Timex.now(), user_id, message_map}
    )
  end

  def get_messages_by_city_id() do
    :dets.select(:chat, [{{:"$1", :_, :"$3"}, [], [:"$_"]}])
  end

  def get_all_by_city(city_id) do
    :dets.select(
      :chat,
      fun do
        {x, y, z, j, l} = item when y == ^city_id ->
          item
      end
    )
    |> Enum.sort_by(fn {_, _, d, _, _} -> d end, Time)
  end

  def delete_all() do
    :dets.delete_all_objects(:chat)
  end
end
