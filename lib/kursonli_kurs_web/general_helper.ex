defmodule KursonliKursWeb.GeneralHelper do
  import KursonliKursWeb.Gettext
  @moduledoc false

  @doc """
  Parse date to Timex format
  "2022-12-08T18:51:42.417Z" -> ~U[2022-12-08 18:51:42.417Z]
  """
  @spec parse_date(String.t()) :: {:ok, Timex.Date.t()} | {:error, :badarg}
  def parse_date(date) do
    case Timex.parse(date, "{ISO:Extended:Z}") do
      {:ok, timex_date} -> {:ok, timex_date}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Hash string to SHA256
  "993" -> "40FB7164E459A38813F304E3B45DB2B074BE149818924E46FDC49CC38A3E4955"
  """
  @spec hash_str(String.t()) :: String.t()
  def hash_str(str) do
    :crypto.hash(:sha256, str) |> Base.encode16()
  end

  @doc """
  Generate random string in upper case
  For example: ""PJ8JVMBLVI""
  """
  def generate_random_str(count) do
    for _ <- 1..count,
        into: "",
        do:
          <<Enum.random('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')>>
          |> String.upcase()
  end

  @doc """
  Get info from config for templates
  For example: check_config("order_type") -> ["purchase", "sale"]
  """
  def check_config(conf_atom) do
    Application.get_env(:kursonli_kurs, String.to_atom(conf_atom))
    |> Enum.map(fn x -> Atom.to_string(x) end)
  end

  def date_to_string_data(date), do: Timex.format!(date, "{0D}.{0M}.{YYYY}")

  def date_to_string_time(date), do: Timex.format!(date, "{h24}:{m}:{s}")
  def date_to_string_time_h(date), do: Timex.format!(date, "{h24}")
  def date_to_string_time_m(date), do: Timex.format!(date, "{m}")
  def date_to_string_time_s(date), do: Timex.format!(date, "{s}")

  def date_to_string_time_personal(date),
    do: Timex.format!(date, "{0D} #{month_translate_ru(date.month)} {YYYY} {h24}:{m}")

  def date_to_string_all(date),
    do: "#{date.year}-#{date.month}-#{date.day} #{date.hour}:#{date.minute}:#{date.second}"

  def get_image_path(nil, type, filial_id) do
    {:ok, setting} = KursonliKurs.Context.Settings.do_get(filial_id: filial_id)

    case type do
      :logo -> setting.logo
      :photo -> setting.photo
    end
  end

  def get_image_path(upload, type, _filial_id) do
    new_path =
      case type do
        :logo -> Path.expand("priv/static/images/logo/#{upload.filename}")
        :photo -> Path.expand("priv/static/images/photo/#{upload.filename}")
      end

    File.cp(upload.path, new_path)

    case type do
      :logo -> "images/logo/#{upload.filename}"
      :photo -> "images/photo/#{upload.filename}"
    end
  end

  def normalize_order_type(type, opts) do
    case opts do
      :single ->
        if type == "sale", do: gettext("Продажa"), else: gettext("Покупкa")

      :multi ->
        if type == "sale", do: gettext("Продажу"), else: gettext("Покупку")
    end
  end

  def normalize_status_trade(type) do
    case type do
      :active -> gettext("Активная")
      :fail -> gettext("Отклонено")
      :success -> gettext("Принята")
    end
  end

  def compare_workers_id(worker1, worker2) do
    if worker1 > worker2, do: worker2 <> worker1, else: worker1 <> worker2
  end

  def find_value_by_short_name(course, key_order \\ :value_for_purchase, short_name \\ "EUR") do
    course
    |> Enum.filter(fn x -> x.short_name == short_name end)
    |> Enum.map(fn x ->
      value = Map.get(x, key_order)
      if value != nil and x.short_name == short_name, do: value, else: "-"
    end)
  end

  @doc """
  Modify UTC DateTime to display
  """
  def humanizated_date(date) when is_map(date),
    do: hum_date(Timex.diff(Timex.shift(Timex.now(), hours: 6), date, :second))

  def humanizated_date(_date), do: "-"

  defp hum_date(d) when d < 0, do: "-"
  defp hum_date(d) when d >= 0 and d <= 1, do: gettext("1 секунду назад")
  defp hum_date(d) when d > 1 and d <= 4, do: "#{d} #{gettext("секунды назад")}"
  defp hum_date(d) when d > 4 and d <= 60, do: "#{d} #{gettext("секунд назад")}"
  defp hum_date(d) when d > 1 * 60 and d <= 2 * 60, do: gettext("Минуту назад")
  defp hum_date(d) when d > 2 * 60 and d <= 4 * 60, do: "#{div(d, 60)} #{gettext("минуты назад")}"
  defp hum_date(d) when d > 4 * 60 and d <= 60 * 60, do: "#{div(d, 60)} #{gettext("минут назад")}"
  defp hum_date(d) when d > 60 * 60 and d <= 2 * 60 * 60, do: gettext("1 час назад")
  defp hum_date(d) when d > 2 * 60 * 60 and d <= 4 * 60 * 60, do: "#{div(d, 60 * 60)} #{gettext("часа назад")}"
  defp hum_date(d) when d > 4 * 60 * 60 and d <= 20 * 60 * 60, do: "#{div(d, 60 * 60)} #{gettext("часов назад")}"
  defp hum_date(d) when d > 20 * 60 * 60 and d <= 21 * 60 * 60, do: "#{div(d, 60 * 60)} #{gettext("час назад")}"
  defp hum_date(d) when d > 21 * 60 * 60 and d <= 24 * 60 * 60, do: "#{div(d, 60 * 60)} #{gettext("часa назад")}"
  defp hum_date(d) when d > 24 * 60 * 60, do: gettext("Больше суток назад")

  defp month_translate_ru(month) do
    case month do
      01 -> gettext("января")
      02 -> gettext("февраля")
      03 -> gettext("марта")
      04 -> gettext("апреля")
      05 -> gettext("мая")
      06 -> gettext("июня")
      07 -> gettext("июля")
      08 -> gettext("августа")
      09 -> gettext("сентября")
      10 -> gettext("октября")
      11 -> gettext("ноября")
      12 -> gettext("декабря")
    end
  end
end
