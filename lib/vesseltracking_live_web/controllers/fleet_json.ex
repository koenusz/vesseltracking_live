defmodule VesseltrackingLiveWeb.FleetJSON do
  alias VesseltrackingLive.Fleets.Fleet

  @doc """
  Renders a list of fleets.
  """
  def index(%{fleets: fleets}) do
    %{data: for(fleet <- fleets, do: data(fleet))}
  end

  @doc """
  Renders a single fleet.
  """
  def show(%{fleet: fleet}) do
    %{data: data(fleet)}
  end

  defp data(%Fleet{} = fleet) do
    %{
      id: fleet.id,
      name: fleet.name,
      vessels: fleet.vessels
    }
  end
end
