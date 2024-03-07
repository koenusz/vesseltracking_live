defmodule VesseltrackingLiveWeb.FleetControllerTest do
  use VesseltrackingLiveWeb.ConnCase

  alias VesseltrackingLive.Fleets
  alias VesseltrackingLive.Fleets.Fleet
  alias Plug.Conn

  import Support.Fixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all fleets", %{conn: conn} do
      conn = get(conn, Routes.fleet_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create fleet" do
    test "renders fleet when data is valid", %{conn: conn} do
      company = company_fixture()

      input =
        @create_attrs
        |> Map.put(:company_id, company.id)

      conn = post(conn, Routes.fleet_path(conn, :create), fleet: input)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.fleet_path(conn, :show, id))

      assert json_response(conn, 200)["data"] == %{
               "vessels" => [],
               "id" => id,
               "name" => "some name",
               "authorized_users" => [],
               "companyId" => company.id
             }
    end

    test "get fleet by user_id", %{conn: conn} do
      authorization = authorization_fixture()

      conn = Conn.assign(conn, :user_id, authorization.user_id)
      conn = get(conn, Routes.fleet_path(conn, :get_fleets_by_user))

      [response] = json_response(conn, 200)["data"]
      assert response["vessels"] == []
      assert response["name"] == "some name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.fleet_path(conn, :create), fleet: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update fleet" do
    setup [:create_fleet]

    test "renders fleet when data is valid", %{
      conn: conn,
      fleet: %Fleet{id: id, company_id: company_id} = fleet
    } do
      conn = put(conn, Routes.fleet_path(conn, :update, fleet), fleet: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.fleet_path(conn, :show, id))

      assert json_response(conn, 200)["data"] == %{
               "vessels" => [],
               "id" => id,
               "name" => "some updated name",
               "authorized_users" => [],
               "companyId" => company_id
             }
    end

    test "renders errors when data is invalid", %{conn: conn, fleet: fleet} do
      conn = put(conn, Routes.fleet_path(conn, :update, fleet), fleet: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete fleet" do
    setup [:create_fleet]

    test "deletes chosen fleet", %{conn: conn, fleet: fleet} do
      conn = delete(conn, Routes.fleet_path(conn, :delete, fleet))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, Routes.fleet_path(conn, :show, fleet))
      end)
    end
  end

  defp create_fleet(_) do
    fleet = fleet_fixture()
    {:ok, fleet: fleet}
  end
end
