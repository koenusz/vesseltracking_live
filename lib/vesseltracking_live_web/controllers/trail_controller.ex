defmodule VesseltrackingLiveWeb.TrailController do
  use VesseltrackingLiveWeb, :controller

  alias VesseltrackingLive.Track
  alias VesseltrackingLive.Track.Trail
  alias VesseltrackingLive.Track.Step

  action_fallback(VesseltrackingLiveWeb.FallbackController)

  def step(_conn, step_params) do
    {:ok, point} =
      step_params["step_params"]["step"]["point"]
      |> Track.translate()

    timestamp =
      case step_params["step_params"]["step"]["origin_timestamp"] do
        %DateTime{} = dt -> dt
        timestamp -> DateTime.from_unix!(timestamp, :millisecond)
      end

    tracking_id = step_params["step_params"]["tracking_id"]
    step = %Step{origin_timestamp: timestamp, point: point}
    store_and_forward_step(tracking_id, step)
    :success_no_content
  end

  defp store_and_forward_step(tracking_id, step) do
    {:ok, _} = Track.add_step(tracking_id, step)

    VesseltrackingLiveWeb.Endpoint.broadcast!(
      "vessel:" <> tracking_id,
      "message",
      %{"body" => step}
    )
  end

  def index(conn, _params) do
    trails = Track.list_trails()
    render(conn, "index.json", trails: trails)
  end

  def unclaimed_trails(conn, _params) do
    trails = Track.list_unclaimed_trails()
    render(conn, "index.json", trails: trails)
  end

  def create(conn, %{"trail" => trail_params}) do
    with {:ok, %Trail{} = trail} <- Track.create_trail(trail_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.trail_path(conn, :show, trail))
      |> render("show.json", trail: trail)
    end
  end

  def show(conn, %{"id" => id}) do
    trail = Track.get_trail!(id)
    render(conn, "show.json", trail: trail)
  end

  def update(conn, %{"id" => id, "trail" => trail_params}) do
    trail = Track.get_trail!(id)

    with {:ok, %Trail{} = trail} <- Track.update_trail(trail, trail_params) do
      render(conn, "show.json", trail: trail)
    end
  end

  def delete(conn, %{"id" => id}) do
    trail = Track.get_trail!(id)

    with {:ok, %Trail{}} <- Track.delete_trail(trail) do
      send_resp(conn, :no_content, "")
    end
  end
end
