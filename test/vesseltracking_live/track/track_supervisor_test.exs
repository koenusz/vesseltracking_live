defmodule VesseltrackingLive.Track.TrackSupervisorTest do
  use VesseltrackingLive.DataCase

  test "start a trackworker" do
    assert {:ok, _pid} = VesseltrackingLive.Track.Supervisor.start_child("123456789")
  end
end
