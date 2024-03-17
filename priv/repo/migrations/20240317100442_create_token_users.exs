defmodule VesseltrackingLive.Repo.Migrations.CreateTokenUsers do
  use Ecto.Migration

  def change do
    create table(:token_users) do
      add :username, :string
      add :pubkey, :binary
      add :approved?, :boolean, default: false, null: false
      add :created_at, :utc_datetime
      add :expires_at, :utc_datetime
      add :comment, :string
    end
  end
end
