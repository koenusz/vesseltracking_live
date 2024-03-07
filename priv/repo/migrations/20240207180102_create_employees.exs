defmodule Vesseltracking.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:company_id, references(:companies, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:employees, [:user_id, :company_id]))
  end
end
