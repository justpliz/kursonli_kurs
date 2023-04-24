defmodule KursonliKurs.EtsStorage.ScrappedData do
  def init(_) do
    {:ok, []}
  end

  # Запускает БД
  def start_link(state \\ []) do
    create()
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def create() do
    :ets.new(:scrapped_data, [:set, :public, :named_table])
    {:ok, ""}
  end

  def insert(currency, buy, sale) do
    :ets.insert_new(:scrapped_data, {currency, buy, sale})
  end

  def get(currency) do
    :ets.lookup(:scrapped_data, currency)
  end

  def get_by_id(id) do
    case :ets.lookup(:scrapped_data, id) do
      [item] -> {:ok, item}
      [] -> {:error, :not_found}
    end
  end

  def update(id, buy, sale) do
    with {:ok, {currency, _, _}} <- get_by_id(id) do
      :ets.insert(:scrapped_data, {currency, buy, sale})
      :ok
    end
  end

  def get_all() do
    usd = :ets.lookup(:scrapped_data, "USD") |> hd |> Tuple.to_list()
    eur = :ets.lookup(:scrapped_data, "EUR") |> hd |> Tuple.to_list()
    rub = :ets.lookup(:scrapped_data, "RUB") |> hd |> Tuple.to_list()
    [usd, eur, rub]
  end
end
