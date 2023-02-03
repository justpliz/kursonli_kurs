defmodule KursonliKurs.Repo.Migrations.CreateSettingsTable do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :tags, {:array, :string}
      add :coordinates, {:array, :string}
      add :address_2gis, :string
      add :firm_id, :string
      add :logo, :string
      add :photo, :string
      add :license, :string
      add :email, :string
      add :subdomen, :string
      add :description, :text
      add :schedule, :jsonb
      add :phones, :jsonb
      add :qualities, :jsonb
      add :colors, :jsonb

      add :filial_id, references(:filials, type: :uuid, on_delete: :nothing)
    end

    create index(:settings, [:address_2gis, :phones, :coordinates])
  end
end
