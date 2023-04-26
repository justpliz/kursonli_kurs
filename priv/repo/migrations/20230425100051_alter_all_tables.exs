defmodule KursonliKurs.Repo.Migrations.AlterAllTables do
  use Ecto.Migration

  def change do
    drop_if_exists table("courses_history")

    drop index(:courses, [:currency_id, :filial_id])
    create unique_index(:courses, [:currency_id, :filial_id])

    rename table("courses"), :value_for_purchase, to: :buy
    rename table("courses"), :value_for_sale, to: :sale

    rename table("settings"), :subdomen, to: :slug
    rename table("settings"), :address_2gis, to: :address

    alter table(:cities) do
      remove :short_name
      remove :index
    end

    alter table(:notifications) do
      remove :photo
    end

    alter table(:settings) do
      add :url, :string
      remove :schedule
    end

    alter table(:orders) do
      remove :type
    end

    OrderType.drop_type()
    OrderType.create_type()

    alter table(:orders) do
      add :type, :order_type
    end
  end

  # alter table(:filials) do
  #   remove :filial_address
  #   remove :visible_course_status
  # end

  # alter table(:cities) do
  #   add :timezone, :string
  # end

  # alter table(:settings) do
  #   add :visible_course_status, :boolean, default: :false, null: false
  # end
end
