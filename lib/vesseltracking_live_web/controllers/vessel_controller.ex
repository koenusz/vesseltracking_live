defmodule VesseltrackingLiveWeb.VesselController do
  use VesseltrackingLiveWeb, :controller

  alias VesseltrackingLive.Fleets.Vessel
  alias VesseltrackingLive.Fleets

  action_fallback VesseltrackingLiveWeb.FallbackController

  def show(conn, %{"id" => id}) do
    Fleets.get_vessel(id)
    |> case do
      %Vessel{} = vessel -> render(conn, :show, vessel: vessel)
      _ -> {:error, :not_found}
    end
  end
end
