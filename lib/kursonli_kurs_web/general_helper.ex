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
  def genrate_random_str(count) do
    for _ <- 1..count,
        into: "",
        do: <<Enum.random('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')>>
    |> String.upcase
  end

  @doc """
  Get info from config for templates
  For example: check_config("order_type") -> [:purchase, :sale]
  """
  def check_config(conf_atom) do
    Application.get_env(:kursonli_kurs, String.to_atom(conf_atom))
  end
end
