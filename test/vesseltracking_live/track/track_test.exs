defmodule VesseltrackingLive.TrackTest do
  use VesseltrackingLive.DataCase

  alias VesseltrackingLive.Track
  alias VesseltrackingLive.Track.Step
  import VesseltrackingLive.TrackFixtures
  import VesseltrackingLive.AccountsFixtures

  @one_point %Geo.Point{coordinates: {20, 30}}

  @today Date.utc_today()

  @tracking_id "some tracking_id"

  @valid_attrs %{
    day: @today,
    steps: [@one_point |> Step.from_point() |> Step.to_map()],
    tracking_id: @tracking_id
  }

  @invalid_attrs %{day: nil, steps: %{}, tracking_id: nil}

  @step %Step{origin_timestamp: DateTime.utc_now(), point: %Geo.Point{coordinates: {10, 11}}}

  setup %{} do
    {:ok, trail} = trail_fixture(@valid_attrs)

    %{trail: trail}
  end

  describe "adding steps" do
    test "add a point to an existing trail", %{trail: trail} do
      Track.add_step(trail.tracking_id, @step)
      returned = Track.get_trail_from_worker(trail.tracking_id)

      assert trail.tracking_id == returned.tracking_id
      coordinates = Enum.map(returned.steps, fn step -> step["point"].coordinates end)
      assert coordinates |> Enum.member?(@step.point.coordinates)
    end

    test "add a point to a non existing trail" do
      tracking_id = "freshly started"

      Track.add_step(tracking_id, @step)

      returned = Track.get_trail_from_worker(tracking_id)

      assert tracking_id == returned.tracking_id
      coordinates = Enum.map(returned.steps, fn step -> step["point"].coordinates end)
      assert coordinates |> Enum.member?(@step.point.coordinates)
    end
  end

  describe "trails" do
    alias VesseltrackingLive.Track.Trail

    test "list_trails/0 returns all trails", %{trail: trail} do
      assert Track.list_trails() == [trail]
    end

    test "get_trail!/1 returns the trail with given id", %{trail: trail} do
      assert Track.get_trail!(trail.id) == trail
    end

    test "get_last_trails_by_tracking_id/2 returns a list of trails", %{trail: trail} do
      assert Track.get_last_trails_by_tracking_id(@tracking_id, 1) == [trail]
    end

    test "get_todays_trail/1 returns a trail", %{trail: trail} do
      assert trail == Track.get_todays_trail(@tracking_id)
    end

    test "create_trail/1 with valid data creates a trail" do
      assert {:ok, %Trail{} = trail} = Track.create_trail(@valid_attrs)
      assert trail.day == @today
      assert trail.steps |> List.first() |> (fn step -> step["point"] end).() == @one_point
      assert trail.tracking_id == @tracking_id
    end

    test "create_trail/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Track.create_trail(@invalid_attrs)
    end

    test "update_trail/2 with valid data updates the trail", %{trail: trail} do
      new_step = %Step{
        origin_timestamp: DateTime.utc_now(),
        point: %Geo.Point{coordinates: {10, 11}}
      }

      update_attrs = %{
        day: ~D[2011-05-18],
        steps: [new_step | trail.steps],
        tracking_id: "some updated tracking_id"
      }

      assert {:ok, trail} = Track.update_trail(trail, update_attrs)
      assert %Trail{} = trail
      assert trail.day == ~D[2011-05-18]
      assert trail.steps |> length() == 2
      assert trail.tracking_id == "some updated tracking_id"
    end

    test "update_trail/2 with invalid data returns error changeset", %{trail: trail} do
      assert {:error, %Ecto.Changeset{}} = Track.update_trail(trail, @invalid_attrs)
      assert trail == Track.get_trail!(trail.id)
    end

    test "delete_trail/1 deletes the trail", %{trail: trail} do
      assert {:ok, %Trail{}} = Track.delete_trail(trail)
      assert_raise Ecto.NoResultsError, fn -> Track.get_trail!(trail.id) end
    end

    test "change_trail/1 returns a trail changeset", %{trail: trail} do
      assert %Ecto.Changeset{} = Track.change_trail(trail)
    end
  end
end
