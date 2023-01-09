defmodule KursonliKurs.Repo.Migrations.AddTariffForOrgTable do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :address, :string

      add :tariff_id, references(:tariffs, type: :uuid, on_delete: :nothing)
      add :paid_up_to, :naive_datetime
    end
  end
end
