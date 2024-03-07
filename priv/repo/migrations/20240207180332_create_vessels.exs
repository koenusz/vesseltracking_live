defmodule Vesseltracking.Repo.Migrations.CreateVessels do
  use Ecto.Migration

  def change do
    create table(:vessels) do
      add(:name, :string, null: false)
      add(:tracking_id, :string, null: false)
      add(:fleet_id, references(:fleets, on_delete: :nothing), null: false)
      timestamps()
    end

    create(index(:vessels, [:fleet_id]))
  end
end
