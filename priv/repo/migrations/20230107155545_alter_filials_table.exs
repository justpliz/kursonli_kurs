defmodule KursonliKurs.Repo.Migrations.AlterFilialsTable do
  use Ecto.Migration

  def change do
    alter table(:filials) do
      add :address, :string

      add :city_id, references(:cities, type: :uuid, on_delete: :nothing)
    end
  end
end
