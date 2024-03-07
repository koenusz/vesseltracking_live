defmodule VesseltrackingLiveWeb.FleetController do
  use VesseltrackingLiveWeb, :controller

  alias VesseltrackingLive.{Fleets, Fleets.Fleet}

  def get_fleets_by_user(conn, _params) do
    fleets = Fleets.get_fleets_by_user!(conn.assigns[:user_id])
    render(conn, "index.json", fleets: fleets)
  end

  def get_fleets_by_company(conn, %{"id" => id}) do
    fleets = Fleets.get_fleets_by_company(id)
    render(conn, "index.json", fleets: fleets)
  end

  def index(conn, _params) do
    fleets = Fleets.list_fleets()
    render(conn, "index.json", fleets: fleets)
  end

  def create(conn, %{"fleet" => fleet_params}) do
    with {:ok, %Fleet{} = fleet} <- Fleets.create_fleet(fleet_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.fleet_path(conn, :show, fleet))
      |> render("show.json", fleet: fleet)
    end
  end

  def show(conn, %{"id" => id}) do
    fleet = Fleets.get_fleet!(id)
    render(conn, "show.json", fleet: fleet)
  end

  def update(conn, %{"id" => id, "fleet" => fleet_params}) do
    fleet = Fleets.get_fleet!(id)

    with {:ok, %Fleet{} = fleet} <- Fleets.update_fleet(fleet, fleet_params) do
      render(conn, "show.json", fleet: fleet)
    end
  end

  def delete(conn, %{"id" => id}) do
    fleet = Fleets.get_fleet!(id)

    with {:ok, %Fleet{}} <- Fleets.delete_fleet(fleet) do
      send_resp(conn, :no_content, "")
    end
  end
end
