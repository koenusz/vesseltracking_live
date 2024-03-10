defmodule VesseltrackingLiveWeb.TrailControllerTest do
  use VesseltrackingLiveWeb.ConnCase

  alias VesseltrackingLive.Track
  alias VesseltrackingLive.Track.Trail
  alias VesseltrackingLive.Track.Step

  import Support.Fixtures

  @point %Geo.Point{coordinates: {15.0, 15.0}}
  @one_point %Geo.Point{coordinates: {20, 30}}
  @two_point %Geo.Point{coordinates: {25, 30}}
  @steps [
    @one_point |> Step.from_point() |> Step.to_map(),
    @two_point |> Step.from_point() |> Step.to_map()
  ]

  @create_attrs %{day: ~D[2010-04-17], steps: @steps, tracking_id: "some tracking_id"}

  @invalid_attrs %{day: nil, steps: nil, tracking_id: nil}

  @directory ["test", "support", "gtt_testdata"]
  @directip ["Direct IP MsgPack example.sbd"]

  alias VesseltrackingLive.GTTDecoder

  def fixture(:trail) do
    {:ok, trail} = Track.create_trail(@create_attrs)
    trail
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "step" do
    test "add step to trail", %{conn: conn} do
      step = @point |> Step.from_point() |> Step.to_map()

      args = %{
        "step" => step,
        "tracking_id" => "test: add step to trail"
      }

      conn = post(conn, Routes.trail_path(conn, :step), step_params: args)
      assert json_response(conn, 204)
    end
  end

  describe "index" do
    test "lists all trails", %{conn: conn} do
      conn = get(conn, Routes.trail_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all unclaimed trails", %{conn: conn} do
      trail = fixture(:trail)
      {:ok, used_trail} = trail_fixture()
      vessel_fixture(%{tracking_id: used_trail.tracking_id})

      conn = get(conn, Routes.trail_path(conn, :unclaimed_trails))

      result = json_response(conn, 200)["data"]

      assert length(result) == 1
      [one] = result
      assert one["id"] == trail.id
    end
  end

  describe "create trail" do
    test "renders trail when data is valid", %{conn: conn} do
      conn = post(conn, Routes.trail_path(conn, :create), trail: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.trail_path(conn, :show, id))

      response = json_response(conn, 200)["data"]
      assert response["id"] == id
      assert response["day"] == "2010-04-17"
      assert response["tracking_id"] == "some tracking_id"

      steps = response["steps"]
      points = steps |> Enum.map(fn step -> step["point"] end)

      assert points == [
               %{"coordinates" => [20, 30], "type" => "Point"},
               %{"coordinates" => [25, 30], "type" => "Point"}
             ]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.trail_path(conn, :create), trail: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update trail" do
    setup [:create_trail]

    test "renders trail when data is valid", %{conn: conn, trail: %Trail{id: id} = trail} do
      mapped_steps = trail.steps

      update_attrs = %{
        day: ~D[2011-05-18],
        steps: [@point |> Step.from_point() |> Step.to_map() | mapped_steps],
        tracking_id: "some updated tracking_id"
      }

      conn = put(conn, Routes.trail_path(conn, :update, trail), trail: update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.trail_path(conn, :show, id))

      response = json_response(conn, 200)["data"]
      assert response["id"] == id
      assert response["day"] == "2011-05-18"
      assert response["tracking_id"] == "some updated tracking_id"

      steps = response["steps"]
      points = steps |> Enum.map(fn step -> step["point"] end)

      assert points == [
               %{"coordinates" => [15.0, 15.0], "type" => "Point"},
               %{"coordinates" => [20, 30], "type" => "Point"},
               %{"coordinates" => [25, 30], "type" => "Point"}
             ]
    end

    test "renders errors when data is invalid", %{conn: conn, trail: trail} do
      conn = put(conn, Routes.trail_path(conn, :update, trail), trail: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete trail" do
    setup [:create_trail]

    test "deletes chosen trail", %{conn: conn, trail: trail} do
      conn = delete(conn, Routes.trail_path(conn, :delete, trail))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, Routes.trail_path(conn, :show, trail))
      end)
    end
  end

  defp create_trail(_) do
    trail = fixture(:trail)
    {:ok, trail: trail}
  end
end
