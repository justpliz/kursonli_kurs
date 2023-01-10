defmodule KursonliKurs.Repo.Migrations.CreateOrdersTable do
  use Ecto.Migration

  def change do
    OrderType.create_type()
    OrderTransfer.create_type()
    OrderStatus.create_type()

    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :date, :naive_datetime

      add :course_id, references(:courses, type: :uuid, on_delete: :nothing)
      add :volume, :string
      add :terms, :string, size: 30
      add :transfer, :order_transfer
      add :limit, :string
      add :type, :order_type
      add :status, :order_status

      add :filial_id, references(:filials, type: :uuid, on_delete: :nothing)
      add :worker_id, references(:workers, type: :uuid, on_delete: :nothing)

      timestamps()
    end
  end
end
