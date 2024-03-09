defmodule Vesseltracking.Repo.Migrations.CreateFleets do
  use Ecto.Migration

  def change do
    create table(:fleets) do
      add(:name, :string, null: false)
      timestamps()
    end
  end
end
