defmodule KursonliKurs.Repo.Migrations.CreateFiliasCurrenciesTable do
  use Ecto.Migration

  def change do
    create table(:filials_currencies) do
      add :filial_id, references(:filials, type: :uuid, on_delete: :nothing)
      add :currency_id, references(:currencies)
    end

    create unique_index(:filials_currencies, [:filial_id, :currency_id])
  end
end
