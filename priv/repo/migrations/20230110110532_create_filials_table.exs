defmodule KursonliKurs.Repo.Migrations.CreateFilialsTable do
  use Ecto.Migration

  def change do
    PaymentStatus.create_type()

    create table(:filials, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string
      add :paid_up_to, :naive_datetime
      add :payment_status, :payment_status
      add :filial_active_status, :active_status

      add :city_id, references(:cities, on_delete: :nothing)
      add :organization_id, references(:organizations, type: :uuid, on_delete: :nothing)
      add :tariff_id, references(:tariffs, on_delete: :nothing)

      timestamps()
    end

    create index("filials", [:name], unique: true)
    create index(:filials, [:city_id, :organization_id, :tariff_id])
  end
end
