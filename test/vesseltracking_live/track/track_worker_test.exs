defmodule VesseltrackingLive.Track.TrackworkerTest do
  use VesseltrackingLive.DataCase

  alias VesseltrackingLive.Track.{Step, Trackworker, Trail}
  alias VesseltrackingLive.Track
  alias Geo.{Point}

  @point %Point{coordinates: {15, 30}}

  @tracking_id "test_id"

  setup do
    track_worker = start_supervised!({Trackworker, [tracking_id: @tracking_id]})
    %{track_worker: track_worker}
  end

  describe "worker tests" do
    test "start_link/2 with optional init Trail" do
      tracking_id = "my awesome trail"
      {:ok, _server} = Trackworker.start_link(tracking_id: tracking_id)

      assert %Trail{} = Trackworker.get_trail(tracking_id)
    end

    test "add_point_to_trail/2" do
      {:ok, result} =
        Trackworker.add_step(@tracking_id, @point |> Step.from_point() |> Step.to_map())

      assert @point == result.steps |> List.first() |> (fn item -> item["point"] end).()
    end

    test "add_point_to_trail/2, A new trail is needed for a new day" do
      {:ok, result} =
        Trackworker.add_step(@tracking_id, @point |> Step.from_point() |> Step.to_map())

      assert @point == result.steps |> List.first() |> (fn item -> item["point"] end).()
    end

    test "Store worker state in the database" do
      Trackworker.store_state(@tracking_id)
      assert [%Trail{}] = Track.get_last_trails_by_tracking_id(@tracking_id, 1)
    end
  end
end
