defmodule VesseltrackingLiveWeb.AuthorizationController do
  use VesseltrackingLiveWeb, :controller

  alias VesseltrackingLive.Fleets
  alias VesseltrackingLive.Fleets.Authorization

  import Ecto.Query, warn: false

  action_fallback(VesseltrackingLiveWeb.FallbackController)

  def index(conn, _params) do
    authorizations = Fleets.list_authorizations()
    render(conn, "index.json", authorizations: authorizations)
  end

  def init_authorization_page(_conn, _params) do
    # render(conn, "init.json", %{companies: companies, fleets: fleets})
  end

  def list_in_user_ids(conn, %{"userIds" => user_ids}) do
    authorizations = Fleets.list_authorizations_in_userIds(user_ids)
    render(conn, "index.json", authorizations: authorizations)
  end

  # def create(conn, %{"authorization" => authorization_params}) do
  #   with {:ok, %Authorization{} = authorization} <-
  #          Fleets.create_authorization(authorization_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", Routes.authorization_path(conn, :show, authorization))
  #     |> render("show.json", authorization: authorization)
  #   end
  # end

  def show(conn, %{"id" => id}) do
    authorization = Fleets.get_authorization!(id)
    render(conn, "show.json", authorization: authorization)
  end

  def update(conn, %{"id" => id, "authorization" => authorization_params}) do
    authorization = Fleets.get_authorization!(id)

    with {:ok, %Authorization{} = authorization} <-
           Fleets.update_authorization(authorization, authorization_params) do
      render(conn, "show.json", authorization: authorization)
    end
  end

  def update(conn, %{"authorization" => authorization_params, "action" => action}) do
    authorization =
      Fleets.get_authorization_by_fleet_and_employee(
        authorization_params["user_id"],
        authorization_params["fleet_id"]
      )

    case action do
      "delete" ->
        if authorization != nil do
          delete_by_user_id_and_fleet_id(conn, %{"authorization" => authorization_params})
        end

        # "create" ->
        #   if authorization == nil do
        #     create(conn, %{"authorization" => authorization_params})
        #   end
    end

    send_resp(conn, :no_content, "")
  end

  def delete_by_user_id_and_fleet_id(conn, %{"authorization" => authorization_params}) do
    authorization =
      Fleets.get_authorization_by_fleet_and_employee(
        authorization_params["user_id"],
        authorization_params["fleet_id"]
      )

    with {:ok, %Authorization{}} <- Fleets.delete_authorization(authorization) do
      send_resp(conn, :no_content, "")
    end
  end
end
