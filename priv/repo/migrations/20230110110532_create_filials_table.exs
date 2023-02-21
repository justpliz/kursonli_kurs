defmodule KursonliKurs.Repo.Migrations.CreateFilialsTable do
  use Ecto.Migration

  def change do
    create table(:filials, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string
      add :fililal_address, :string
      add :paid_up_to, :date
      add :filial_active_status, :active_status
      add :visible_status, :boolean, default: :false, null: false

      add :city_id, references(:cities, on_delete: :nothing)
      add :organization_id, references(:organizations, type: :uuid, on_delete: :nothing)
      add :tariff_id, references(:tariffs, on_delete: :nothing)

      timestamps()
    end

    create index("filials", [:name], unique: true)
    create index(:filials, [:city_id, :organization_id, :tariff_id])
  end
end
