defmodule KursonliKurs.Repo.Migrations.CreateOrdersTable do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :date, :naive_datetime
      add :rate, :string
      add :volume, :string
      add :terms, :string
      add :transfer, :string
      add :limit, :string

      add :currency, :string
      add :type, :string

      add :user_id, references(:users, type: :uuid, on_delete: :nothing)
      add :organization_id, references(:organizations, type: :uuid, on_delete: :nothing)
      add :filial_id, references(:filials, type: :uuid, on_delete: :nothing)
      add :worker_id, references(:workers, type: :uuid, on_delete: :nothing)

      timestamps()
    end
  end
end
