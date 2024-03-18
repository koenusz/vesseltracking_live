defmodule VesseltrackingLiveWeb.TrackController do
  use VesseltrackingLiveWeb, :controller

  alias VesseltrackingLive.Track

  action_fallback VesseltrackingLiveWeb.FallbackController

  def last_trails(conn, %{"tracking_id" => tracking_id, "days" => days}) do
    trails = Track.get_last_trails_by_tracking_id(tracking_id, days)
    render(conn, :index, trails: trails)
  end
end
