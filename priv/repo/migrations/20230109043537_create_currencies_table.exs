defmodule KursonliKurs.Repo.Migrations.CreateCurrenciesTable do
  use Ecto.Migration

  def change do
    create table(:currencies, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string
      add :short_name, :string
      add :flag, :string
    end
  end
end
