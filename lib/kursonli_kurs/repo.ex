defmodule KursonliKurs.Repo do
  use Ecto.Repo,
    otp_app: :kursonli_kurs,
    adapter: Ecto.Adapters.Postgres
end
