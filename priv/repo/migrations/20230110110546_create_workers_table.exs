defmodule KursonliKurs.Repo.Migrations.CreateWorkersTable do
  use Ecto.Migration

  def change do
    create table(:workers, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :password, :string
      add :phone, :string
      add :email, :string
      add :organization_id, references(:organizations, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create index("workers", [:email, :phone], unique: true)
  end
end
