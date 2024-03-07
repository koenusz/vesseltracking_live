defmodule VesseltrackingLiveWeb.AuthorizationControllerTest do
  use VesseltrackingLiveWeb.ConnCase

  alias VesseltrackingLive.Fleets
  alias VesseltrackingLive.Fleets.Authorization
  alias Plug.Conn

  import Support.Fixtures

  @update_attrs %{type: "some updated type"}

  def fixture(:authorization) do
    {:ok, authorization} = Fleets.create_authorization()
    authorization
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all authorizations", %{conn: conn} do
      conn = get(conn, Routes.authorization_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "init authorization page" do
    test "lists all authorizations", %{conn: conn} do
      authorization = authorization_fixture()

      conn = Conn.assign(conn, :user_id, authorization.user_id)
      conn = get(conn, Routes.authorization_path(conn, :init_authorization_page))

      response = json_response(conn, 200)["data"]

      employees =
        response["companies"]
        |> Enum.fetch!(0)
        |> (fn item -> item["employees"] end).()

      auts =
        response["fleets"]
        |> Enum.fetch!(0)
        |> (fn item -> item["authorized_users"] end).()

      assert auts == employees
    end
  end

  describe "create authorization" do
    test "renders authorization when data is valid", %{conn: conn} do
      user = user_fixture()
      fleet = fleet_fixture()

      conn =
        post(
          conn,
          Routes.authorization_path(conn, :create),
          authorization: %{type: "some type", user_id: user.id, fleet_id: fleet.id}
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.authorization_path(conn, :show, id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "type" => "some type",
               "userId" => user.id,
               "fleetId" => fleet.id
             }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = user_fixture()
      fleet = fleet_fixture()

      conn =
        post(
          conn,
          Routes.authorization_path(conn, :create),
          authorization: %{type: 212, user_id: user.id, fleet_id: fleet.id}
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update authorization" do
    setup [:create_authorization]

    test "renders authorization when data is valid", %{
      conn: conn,
      authorization: %Authorization{id: id} = authorization
    } do
      conn = put(conn, "/api/authorizations/#{id}", authorization: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.authorization_path(conn, :show, id))
      assert json_response(conn, 200)["data"]["type"] == "some updated type"
    end
  end

  describe "delete authorization" do
    setup [:create_authorization]

    test "deletes chosen authorization", %{conn: conn, authorization: authorization} do
      body = %{
        "authorization" => %{
          "user_id" => authorization.user_id,
          "fleet_id" => authorization.fleet_id
        }
      }

      conn = delete(conn, "/api/authorizations/delete", body)
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, Routes.authorization_path(conn, :show, authorization))
      end)
    end
  end

  defp create_authorization(_) do
    authorization = authorization_fixture()
    {:ok, authorization: authorization}
  end
end
