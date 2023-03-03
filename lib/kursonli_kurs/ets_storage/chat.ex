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

      :logger.info("CHANNEL INSERT -> #{id}")

      table =
        {Ecto.UUID.generate(), id, Timex.now("Asia/Almaty"), user_id,
         default_message_map(message_map, %{
           "user_one" => user_id,
           "user_two" => worker_id
         })}

      :dets.insert_new(
        :chat,
        table
      )

      table
    end
  end

  def get_chats_user(user_id, city_id) do
    KursonliKurs.Context.Cities.get_all_users_by_city(city_id)
    |> Enum.map(fn item ->
      id = GeneralHelper.compare_workers_id(user_id, item.worker_id)
      message = KursonliKurs.EtsStorage.Chat.get_all_by_city(id)

      message =
        message
        |> Enum.filter(fn {_, _, _, _, message} ->
          get_in(message, ["is_visible", user_id])
        end)

      if message != [] do
        Map.put(item, :channel_id, item.worker_id)
      end
    end)
    |> Enum.filter(fn item -> item != nil end)
  end

  def get_all_by_city(worker_id) do
    :dets.select(
      :chat,
      fun do
        {x, y, z, j, l} = item when y == ^worker_id ->
          item
      end
    )
    |> Enum.sort_by(fn {_, _, d, _, _} -> d end, :desc)
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
      :dets.insert(:chat, {x, y, z, j, new_map})
      {:ok, new_map}
    end
  end

  def update_is_visible_users(worker_id_or_channel_id, user_id) do
    get_all_by_city(worker_id_or_channel_id)
    |> Enum.map(fn {id, _, _, _, object_message_map} ->
      IO.inspect(object_message_map)
      update_by_id_message(id, put_in(object_message_map, ["is_visible", user_id], false))
    end)
  end

  def delete_all() do
    :dets.delete_all_objects(:chat)
  end

  # Дефолтная мапа что должно быть в каждом сообщении
  defp default_message_map(map, params \\ %{}) when is_map(map) do
    Map.merge(map, %{
      "is_visible" => %{
        "#{params["user_one"]}" => true,
        "#{params["user_two"]}" => true
      }
    })
  end

  @doc """
  Удаляет по id_Channel все сообщения
  """
  def delete_by_id_channel(channel_id) do
    channel_id |> IO.inspect(label: "channel_id")

    :dets.select_delete(
      :chat,
      fun do
        {x, y, z, j, l} ->
          y == ^channel_id
      end
    )
  end
end
