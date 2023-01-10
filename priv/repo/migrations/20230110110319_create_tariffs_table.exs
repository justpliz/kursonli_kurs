defmodule KursonliKurs.Repo.Migrations.CreateTariffsTable do
  use Ecto.Migration

  def change do
    create table(:tariffs, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string
      add :description, :text
    end

    create index("tariffs", [:name], unique: true)
  end
end
