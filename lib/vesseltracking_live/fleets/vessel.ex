defmodule VesseltrackingLive.Fleets.Vessel do
  use Ecto.Schema
  import Ecto.Changeset
  alias VesseltrackingLive.{Fleets.Vessel, Fleets.Fleet}

  schema "vessels" do
    field(:name, :string)
    field(:tracking_id, :string)
    field(:image, :string)
    belongs_to(:fleet, Fleet)
    timestamps()
  end

  @doc false
  def changeset(%Vessel{} = vessel, attrs) do
    vessel
    |> cast(attrs, [:fleet_id, :name, :tracking_id])
    |> validate_required([:name, :tracking_id])
  end

  def generate_tracking_id(%Vessel{} = vessel, attrs) do
    vessel
    |> cast(attrs, [:fleet_id, :name, :tracking_id])
    |> put_change(:tracking_id, random_string(10))
    |> validate_required([:name, :tracking_id, :fleet_id])
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end
end
