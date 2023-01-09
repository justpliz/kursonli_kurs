defmodule KursonliKurs.Repo.Migrations.AlterCoursesTable do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      remove :first_name
      remove :last_name
      remove :password
      remove :phone
      remove :filial_id

      add :value_for_sale, :string
      add :value_for_purchase, :string

      add :currency_id, references(:currencies, type: :uuid, on_delete: :nothing)
      # TODO add filial_id
    end
  end
end
