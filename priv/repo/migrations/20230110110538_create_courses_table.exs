defmodule KursonliKurs.Repo.Migrations.CreateCoursesTable do
  use Ecto.Migration

  def change do
    create table(:courses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :value_for_sale, :string
      add :value_for_purchase, :string
      add :date, :naive_datetime

      add :currency_id, references(:currencies, on_delete: :nothing)
      add :filial_id, references(:filials, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create index(:courses, [:currency_id, :filial_id])
  end
end
