defmodule KursonliKurs.Repo.Migrations.CreateCitiesTable do
  use Ecto.Migration

  def change do
    create table(:cities, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string
      add :short_name, :string
      add :index, :string
    end
  end
end
