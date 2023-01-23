defmodule KursonliKurs.Repo.Migrations.CreateSettingsTable do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :tags, {:array, :string}
      add :address, :string
      add :photo, :string
      add :description, :jsonb
      add :coordinates, {:array, :string}
      add :schedule, :jsonb
      add :phones, :jsonb
      add :qualities, :jsonb

      add :filial_id, references(:filials, type: :uuid, on_delete: :nothing)
    end

    create index(:settings, [:address, :phones])
  end
end
