defmodule VesseltrackingLive.Fleets.Authorization do
  use Ecto.Schema
  import Ecto.Changeset
  alias VesseltrackingLive.Fleets.Fleet
  alias VesseltrackingLive.Accounts.User

  schema "authorizations" do
    field(:type, :string, default: "regular")
    belongs_to(:user, User)
    belongs_to(:fleet, Fleet)

    timestamps()
  end

  @doc false
  def changeset(authorization, attrs) do
    authorization
    |> cast(attrs, [:type, :user_id, :fleet_id])
  end
end
