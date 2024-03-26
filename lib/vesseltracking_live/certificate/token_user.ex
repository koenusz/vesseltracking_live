defmodule VesseltrackingLive.Certificate.TokenUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "token_users" do
    field :comment, :string
    field :username, :string
    field :pubkey, :binary
    field :approved?, :boolean, default: false
    field :created_at, :utc_datetime
    field :expires_at, :utc_datetime
  end

  @doc false
  def changeset(token_user, attrs) do
    token_user
    |> cast(attrs, [:username, :pubkey, :approved?, :created_at, :expires_at, :comment])
    |> validate_required([:username, :pubkey, :approved?, :created_at, :expires_at, :comment])
  end
end
