defmodule KursonliKurs.Repo.Migrations.AlterOrdersTable do
  use Ecto.Migration

  def change do
    OrderType.create_type()

    alter table(:orders) do
      remove :currency
      remove :type

      add :type, :order_type

      add :currency_id, references(:currencies, type: :uuid, on_delete: :nothing)
      #TODO add status(defenum) number and chat
    end
  end
end
