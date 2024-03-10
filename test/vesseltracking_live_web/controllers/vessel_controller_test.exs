defmodule VesseltrackingliveWeb.VesselControllerTest do
  use VesseltrackingLiveWeb.ConnCase

  alias VesseltrackingLive.Fleets
  alias VesseltrackingLive.Fleets.Vessel
  import Support.Fixtures

  @update_attrs %{name: "some updated name", tracking_id: "some updated tracking_id"}
  @invalid_attrs %{name: nil, tracking_id: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all vessels", %{conn: conn} do
      conn = get(conn, Routes.vessel_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end

    test "get by fleet_id", %{conn: conn} do
      fleet = fleet_fixture()

      my_vessel = vessel_fixture(%{name: "my vessel", fleet_id: fleet.id})
      my_vessel2 = vessel_fixture(%{name: "my vessel2", fleet_id: fleet.id})

      conn = get(conn, Routes.vessel_path(conn, :get_vesseld_by_fleet_id, fleet.id))
      ids = Enum.map(json_response(conn, 200)["data"], &Map.fetch!(&1, "id"))
      assert Enum.member?(ids, my_vessel.id)
      assert Enum.member?(ids, my_vessel2.id)
    end
  end

  describe "create vessel" do
    test "renders vessel when data is valid", %{conn: conn} do
      fleet = fleet_fixture()

      conn =
        post(conn, Routes.vessel_path(conn, :create),
          vessel: %{name: "some name", fleet_id: fleet.id, tracking_id: "some tracking id"}
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.vessel_path(conn, :show, id))

      assert json_response(conn, 200)["data"]["id"] == id

      assert json_response(conn, 200)["data"]["tracking_id"] == "some tracking id"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.vessel_path(conn, :create), vessel: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update vessel" do
    setup [:create_vessel]

    test "renders vessel when data is valid", %{conn: conn, vessel: %Vessel{id: id} = vessel} do
      conn = put(conn, Routes.vessel_path(conn, :update, vessel), vessel: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.vessel_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name",
               "tracking_id" => "some updated tracking_id"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, vessel: vessel} do
      conn = put(conn, Routes.vessel_path(conn, :update, vessel), vessel: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete vessel" do
    setup [:create_vessel]

    test "deletes chosen vessel", %{conn: conn, vessel: vessel} do
      conn = delete(conn, Routes.vessel_path(conn, :delete, vessel))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, Routes.vessel_path(conn, :show, vessel))
      end)
    end
  end

  defp create_vessel(_) do
    vessel = vessel_fixture()
    {:ok, vessel: vessel}
  end
end
