defmodule Vesseltracking.Repo.Migrations.CreateTrails do
  use Ecto.Migration

  def change do
    create table(:trails) do
      add(:day, :date, null: false)
      add(:tracking_id, :string, null: false)
      add(:steps, {:array, :map}, default: [])

      timestamps()
    end
  end
end
