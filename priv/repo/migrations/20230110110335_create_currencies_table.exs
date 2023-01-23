defmodule KursonliKurs.Repo.Migrations.CreateCurrenciesTable do
  use Ecto.Migration

  def change do
    create table(:currencies) do
      add :name, :string
      add :short_name, :string
      add :flag, :string
    end

    create index("currencies", [:name, :short_name], unique: true)
    create index(:currencies, [:short_name])
  end
end
