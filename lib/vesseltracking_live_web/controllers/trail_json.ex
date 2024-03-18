defmodule VesseltrackingLiveWeb.TrackJSON do
  alias VesseltrackingLive.Track.Trail

  @doc """
  Renders a list of trails.
  """
  def index(%{trails: trails}) do
    %{data: for(trail <- trails, do: data(trail))}
  end

  @doc """
  Renders a single trail.
  """
  def show(%{trail: trail}) do
    %{data: data(trail)}
  end

  defp data(%Trail{} = trail) do
    %{
      id: trail.id,
      day: trail.day,
      steps: trail.steps,
      tracking_id: trail.tracking_id
    }
  end
end
