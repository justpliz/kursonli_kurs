defmodule KursonliKurs.Repo.Migrations.DeleteFilialsCurrenciesTable do
  use Ecto.Migration

  def change do
    drop_if_exists table("filials_currencies")
  end
end
