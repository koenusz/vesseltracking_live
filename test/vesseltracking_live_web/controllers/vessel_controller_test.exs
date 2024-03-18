defmodule VesseltrackingLiveWeb.VesselControllerTest do
  use VesseltrackingLiveWeb.ConnCase

  import VesseltrackingLive.FleetsFixtures

  alias VesseltrackingLive.Fleets.Vessel

  @tracking_id "some tracking_id"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create vessel" do
    setup [:create_vessel]

    test "renders vessel when data is valid", %{conn: conn, vessel: vessel} do
      id = vessel.id
      tid = @tracking_id

      conn = get(conn, ~p"/api/vessels/#{vessel.id}")

      assert %{
               "id" => ^id,
               "name" => "some name",
               "tracking_id" => ^tid
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, vessel: vessel} do
      conn = get(conn, ~p"/api/vessels/#{vessel.id + 1}")
      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  defp create_vessel(_) do
    fleet = fleet_fixture()

    vessel = vessel_fixture(%{fleet_id: fleet.id, tracking_id: @tracking_id})
    %{vessel: vessel}
  end
end
