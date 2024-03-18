defmodule VesseltrackingLiveWeb.FleetController do
  use VesseltrackingLiveWeb, :controller

  alias VesseltrackingLive.Fleets

  action_fallback VesseltrackingLiveWeb.FallbackController

  def fleets_by_user(conn, %{"user_id" => user_id}) do
    fleets = Fleets.get_fleets_by_user!(user_id)
    render(conn, :index, fleets: fleets)
  end
end
