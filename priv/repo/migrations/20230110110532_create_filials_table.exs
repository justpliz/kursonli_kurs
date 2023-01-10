defmodule KursonliKurs.Repo.Migrations.CreateFilialsTable do
  use Ecto.Migration

  def change do
    PaymentStatus.create_type()

    create table(:filials, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string
      add :tags, {:array, :string}
      add :address, :string
      add :photo, :string
      add :description, :text
      add :paid_up_to, :naive_datetime
      add :payment_status, :payment_status

      add :city_id, references(:cities, type: :uuid, on_delete: :nothing)
      add :organization_id, references(:organizations, type: :uuid, on_delete: :nothing)
      add :tariff_id, references(:tariffs, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create index("filials", [:name], unique: true)
  end
end
