defmodule KursonliKurs.EtsStorage.UserOnline do
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
    :ets.new(:online_users, [:set, :public, :named_table])
    {:ok, ""}
  end

  def insert(user_id, city_id, user_map) do
    :ets.insert_new(:online_users, {user_id, city_id, user_id, user_map})
  end

  def get_online_users(city_id) do
    :ets.match_object(:online_users, {:"$1", city_id, :_, :_})
  end

  def delete_online_user(user_id) do
    :ets.delete(:online_users, user_id)
  end

  def get_online_users_current(city_id \\ nil) do
    if is_nil(city_id) do
      get_all()
      |> Enum.count()
    end
  end

  def get_all() do
    :ets.match_object(
      :online_users,
      {:"$1", :_, :_, :_}
    )
    |> Enum.map(fn {user_id, _, _, _} -> user_id end)
  end
end
