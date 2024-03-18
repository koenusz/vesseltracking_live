defmodule VesseltrackingLiveWeb.VesselJSON do
  alias VesseltrackingLive.Fleets.Vessel

  @doc """
  Renders a list of vessels.
  """
  def index(%{vessels: vessels}) do
    %{data: for(vessel <- vessels, do: data(vessel))}
  end

  @doc """
  Renders a single vessel.
  """
  def show(%{vessel: vessel}) do
    %{data: data(vessel)}
  end

  defp data(%Vessel{} = vessel) do
    %{
      id: vessel.id,
      name: vessel.name,
      tracking_id: vessel.tracking_id
    }
  end
end
