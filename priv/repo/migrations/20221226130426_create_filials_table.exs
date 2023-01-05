defmodule KursonliKurs.Repo.Migrations.CreateFilialsTable do
  use Ecto.Migration

  def change do
    create table(:filials, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string
      add :tags, {:array, :string}
      add :organization_id, references(:organizations, type: :uuid, on_delete: :nothing)

      timestamps()
    end
  end
end
