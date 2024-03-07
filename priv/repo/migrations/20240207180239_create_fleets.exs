defmodule Vesseltracking.Repo.Migrations.CreateFleets do
  use Ecto.Migration

  def change do
    create table(:fleets) do
      add(:name, :string, null: false)
      add(:company_id, references(:companies, on_delete: :nothing), null: false)
      timestamps()
    end

    create(index(:fleets, [:company_id]))
    create(unique_index(:fleets, [:name, :company_id]))
  end
end
