defmodule KursonliKurs.EtsStorage.Chat do
  require Logger
  import Ex2ms
  alias KursonliKursWeb.GeneralHelper

  @moduledoc """
  # База чата на DETS
  ## У чата есть всего несколько полей
    {Ecto.UUID.generate(), worker_id, Timex.now(), user_id, message_map} -> Сообщения в чате

    - {Уникальный id,-,-,-,-}
    - {-,Айди сотрудника с которым начался чат,-,-,-}
    - {-,-,Время отправления сообщения,-,-}
    - {-,-,-,Айди отправителя,-}
    - {-,-,-,-, Что это такое можно посмотреть снизу}

  ## Что такое message_map ->
    Это Map'а

    У message map может быть тип text и event

    Если type: event то еще прибавляеться ключ - type_event: "active"

    ### Типы type_event
    - active -> Активный у пользольвателя есть возможно принять отклонить
    - fail -> Пользователь отклонил
    - success -> Пользователь принял
  """
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

  # def dialog(worker_id, user_id) do
  #   if user_id > worker_id, do: worker_id <> user_id, else: user_id <> worker_id
  #   :dets.select(
  #     :chat,
  #     fun do
  #       {_x, worker_id, _z, user_id, l} = item when worker_id >  ->
  #         item
  #     end
  #   )
  #   |> Enum.sort_by(fn {_, _, d, _, _} -> d end, Time)
  # end

  def insert_message(user_id, worker_id, message_map, type \\ "user") do
    if type == "city" do
      table = {Ecto.UUID.generate(), user_id, Timex.now("Asia/Almaty"), user_id, message_map}
      :logger.info("CHANNEL INSERT -> #{user_id}")

      :dets.insert_new(
        :chat,
        table
      )

      table
    else
      id = GeneralHelper.compare_workers_id(user_id, worker_id)

      :logger.info("CHANNEL INSERT -> #{ID}")
      table = {Ecto.UUID.generate(), id, Timex.now("Asia/Almaty"), user_id, message_map}

      :dets.insert_new(
        :chat,
        table
      )

      table
    end
  end

  def get_all_by_city(worker_id) do
    :dets.select(
      :chat,
      fun do
        {x, y, z, j, l} = item when y == ^worker_id ->
          item
      end
    )
    |> Enum.sort_by(fn {_, _, d, _, _} -> d end, Time)
  end

  def get_by_id(id) do
    case :dets.lookup(:chat, id) do
      [item] -> {:ok, item}
      [] -> {:error, :not_found}
    end
  end

  @doc """
  # Обновляет message map по Id
  """
  def update_by_id_message(id, message_params) do
    with {:ok, {x, y, z, j, object_message_map} = _item} <- get_by_id(id) do
      new_map = object_message_map |> Map.merge(message_params)
      {:ok, :dets.insert(:chat, {x, y, z, j, new_map})}
    end
  end

  def delete_all() do
    :dets.delete_all_objects(:chat)
  end
end
