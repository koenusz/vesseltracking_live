defmodule VesseltrackingLiveWeb.FleetControllerTest do
  use VesseltrackingLiveWeb.ConnCase

  import VesseltrackingLive.FleetsFixtures
  import VesseltrackingLive.AccountsFixtures

  setup %{conn: conn} do
    user = user_fixture()

    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user}
  end

  describe "index" do
    setup [:create_fleet]

    test "lists all users fleets", %{conn: conn, user: user, fleet: fleet} do
      conn = get(conn, ~p"/api/fleets/#{user.id}")
      assert json_response(conn, 200)["data"] == []

      authorization_fixture(%{user_id: user.id, fleet_id: fleet.id})

      conn = get(conn, ~p"/api/fleets/#{user.id}")
      assert (json_response(conn, 200)["data"] |> hd)["id"] == fleet.id
    end
  end

  defp create_fleet(_) do
    fleet = fleet_fixture()
    %{fleet: fleet}
  end
end
