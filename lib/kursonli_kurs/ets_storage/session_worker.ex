defmodule KursonliKurs.EtsStorage.SessionWorker do
  @table_name :session_storage
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
    :ets.new(@table_name, [:set, :public, :named_table])
    {:ok, ""}
  end

  def insert(user_id) do
    :ets.insert_new(@table_name, {Ecto.UUID.generate(), user_id})
  end

  def get_user_id(opts) do
    :ets.select(
      @table_name,
      fun do
        {id, user_id} = item when ^opts[:user_id] == user_id ->
          id
      end
    )
  end

  def check_user(user_id) do
    get_user_id(%{user_id: user_id})
    |> case do
      [id, _] ->
        delete_by_id(id)
        true

      [_] ->
        false

      [] ->
        false
    end
  end

  def delete_by_id(id) do
    :ets.delete(@table_name, id)
  end
end
