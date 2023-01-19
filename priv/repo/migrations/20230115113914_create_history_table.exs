defmodule KursonliKurs.Repo.Migrations.CreateHistoryTable do
  use Ecto.Migration

  def change do
    create table(:courses_history, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :date, :naive_datetime

      add :filial_id, references(:filials, type: :uuid, on_delete: :nothing)
    end
  end
end
