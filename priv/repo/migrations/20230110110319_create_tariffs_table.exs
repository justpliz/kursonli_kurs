defmodule KursonliKurs.Repo.Migrations.CreateTariffsTable do
  use Ecto.Migration

  def change do
    create table(:tariffs) do
      add :name, :string
      add :price, :string
      add :description, :text
    end

    create index("tariffs", [:name], unique: true)
  end
end
