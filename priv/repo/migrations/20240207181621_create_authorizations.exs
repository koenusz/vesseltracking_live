defmodule Vesseltracking.Repo.Migrations.CreateAuthorizations do
  use Ecto.Migration

  def change do
    create table(:authorizations) do
      add(:type, :string)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:fleet_id, references(:fleets, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:authorizations, [:user_id, :fleet_id]))
  end
end
