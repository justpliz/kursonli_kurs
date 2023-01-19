defmodule KursonliKurs.Repo.Migrations.CreateCitiesTable do
  use Ecto.Migration

  def change do
    create table(:cities) do
      add :name, :string
      add :short_name, :string
      add :index, :string
    end

    create index("cities", [:name, :short_name], unique: true)
  end
end
