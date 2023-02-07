defmodule KursonliKursWeb.GeneralHelper do
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

  def date_to_string_data(date), do: "#{date.year}-#{date.month}-#{date.day}"

  def date_to_string_data_dot(date), do: "#{date.day}.#{date.month}.#{date.year}"

  def date_to_string_time(date), do: "#{date.hour}:#{date.minute}:#{date.second}"

  def date_to_string_all(date),
    do: "#{date.year}-#{date.month}-#{date.day} #{date.hour}:#{date.minute}:#{date.second}"

  def string_date_to_datetime(date),
    do: date |> Timex.parse!("{YYYY}-{0M}-{D}") |> Timex.to_datetime()

  def get_image_path(nil, type) do
    case type do
      :logo -> "images/logo/default_logo.jpg"
      :photo -> "images/logo/default_photo.jpg"
    end
  end

  def get_image_path(upload, type) do
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

  def normalize_order_type(type) do
    if type == "sale" do
      "Продажу"
    else
      "Покупку"
    end
  end

  def normalize_status_trade(type) do
    case type do
      "active" -> "Активная"
      "fail" -> "Отклонено"
      "success" -> "Принята"
    end
  end
end
