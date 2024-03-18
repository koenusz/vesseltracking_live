defmodule VesseltrackingLiveWeb.TrackControllerTest do
  use VesseltrackingLiveWeb.ConnCase

  import VesseltrackingLive.TrackFixtures

  @tracking_id "123456"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "get  trail" do
    setup [:create_trails]

    test "get the last two trails", %{conn: conn} do
      conn = get(conn, ~p"/api/trails/last/#{@tracking_id}/2")

      response = json_response(conn, 200)

      assert length(response["data"]) == 2

      assert Enum.each(response["data"], fn %{"tracking_id" => tracking_id} ->
               tracking_id == @tracking_id
             end)
    end
  end

  defp create_trails(_) do
    trail1 = trail_fixture(%{tracking_id: @tracking_id})

    trail2 =
      trail_fixture(%{
        tracking_id: @tracking_id,
        day: DateTime.utc_now() |> DateTime.add(-1, :day)
      })

    trail3 =
      trail_fixture(%{
        tracking_id: @tracking_id,
        day: DateTime.utc_now() |> DateTime.add(-2, :day)
      })

    %{trails: [trail1, trail2, trail3]}
  end
end
