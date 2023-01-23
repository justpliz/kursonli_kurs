defmodule KursonliKurs.Repo.Migrations.CreateOrdersTable do
  use Ecto.Migration

  def change do
    OrderType.create_type()
    OrderTransfer.create_type()

    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :date, :naive_datetime
      add :volume, :string
      add :course, :string
      add :transfer, :order_transfer
      add :limit, :string
      add :terms, :string, size: 30
      add :type, :order_type
      add :number, :string, size: 6
      add :currency_id, references(:currencies)

      add :filial_id, references(:filials, type: :uuid, on_delete: :nothing)
      add :worker_id, references(:workers, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create index(:orders, [:filial_id, :worker_id, :currency_id])
  end
end
