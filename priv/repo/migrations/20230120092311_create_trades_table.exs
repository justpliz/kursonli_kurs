defmodule KursonliKurs.Repo.Migrations.CreateTradesTable do
  use Ecto.Migration

  def change do
    OrderStatus.create_type()

    create table(:trades) do
      add :worker_id, references(:workers, type: :uuid, on_delete: :nothing)
      add :order_id, references(:orders, type: :uuid, on_delete: :nothing)
      add :terms, :string, size: 30

      add :volume, :string

      add :status, :order_status
      timestamps()
    end

    create index(:trades, [:worker_id, :order_id])
  end
end
