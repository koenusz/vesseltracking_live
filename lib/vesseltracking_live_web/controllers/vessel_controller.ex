defmodule VesseltrackingLiveWeb.VesselController do
  use VesseltrackingLiveWeb, :controller

  alias VesseltrackingLive.Track
  alias VesseltrackingLive.Fleets
  alias VesseltrackingLive.Fleets.Vessel

  action_fallback(VesseltrackingLiveWeb.FallbackController)

  def index(conn, _params) do
    vessels = Fleets.list_vessels()
    render(conn, "index.json", vessels: vessels)
  end

  def init(conn, %{"id" => id}) do
    vessel = Fleets.get_vessel!(id)
    trails = Track.get_last_trails_by_tracking_id(vessel.tracking_id, 3)
    render(conn, "init.json", %{vessel: vessel, trails: trails})
  end

  # def create(conn, %{"vessel" => vessel_params}) do
  #   with {:ok, %Vessel{} = vessel} <- Fleets.create_vessel(vessel_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", Routes.vessel_path(conn, :show, vessel))
  #     |> render("show.json", vessel: vessel)
  #   end
  # end

  def get_vesseld_by_fleet_id(conn, %{"id" => id}) do
    vessels = Fleets.get_vessels_by_fleet_id(id)

    render(conn, "index.json", vessels: vessels)
  end

  def show(conn, %{"id" => id}) do
    vessel = Fleets.get_vessel!(id)
    render(conn, "show.json", vessel: vessel)
  end

  def update(conn, %{"id" => id, "vessel" => vessel_params}) do
    vessel = Fleets.get_vessel!(id)

    with {:ok, %Vessel{} = vessel} <- Fleets.update_vessel(vessel, vessel_params) do
      render(conn, "show.json", vessel: vessel)
    end
  end

  def delete(conn, %{"id" => id}) do
    vessel = Fleets.get_vessel!(id)

    with {:ok, %Vessel{}} <- Fleets.delete_vessel(vessel) do
      send_resp(conn, :no_content, "")
    end
  end
end
