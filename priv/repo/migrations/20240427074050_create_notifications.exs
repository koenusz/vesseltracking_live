defmodule Vesseltracking.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add(:imei, :string)
      add(:message, :string)
      add(:type, :string)
      add(:is_read, :boolean, default: false, null: false)
      add(:created_on, :utc_datetime)
      add(:user_id, references(:users, on_delete: :nothing))

      timestamps()
    end

    create(index(:notifications, [:user_id]))
  end
end
