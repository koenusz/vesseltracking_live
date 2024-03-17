defmodule VesseltrackingLiveWeb.TokenUserController do
  use VesseltrackingLiveWeb, :controller

  alias VesseltrackingLive.Certificate
  alias VesseltrackingLive.Certificate.TokenUser

  action_fallback VesseltrackingLiveWeb.FallbackController

  def request_access(params) do
  end

  def login(params) do
  end

  def index(conn, _params) do
    token_users = Certificate.list_token_users()
    render(conn, :index, token_users: token_users)
  end

  def create(conn, %{"token_user" => token_user_params}) do
    with {:ok, %TokenUser{} = token_user} <- Certificate.create_token_user(token_user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/token_users/#{token_user}")
      |> render(:show, token_user: token_user)
    end
  end

  def show(conn, %{"id" => id}) do
    token_user = Certificate.get_token_user!(id)
    render(conn, :show, token_user: token_user)
  end

  def update(conn, %{"id" => id, "token_user" => token_user_params}) do
    token_user = Certificate.get_token_user!(id)

    with {:ok, %TokenUser{} = token_user} <-
           Certificate.update_token_user(token_user, token_user_params) do
      render(conn, :show, token_user: token_user)
    end
  end

  def delete(conn, %{"id" => id}) do
    token_user = Certificate.get_token_user!(id)

    with {:ok, %TokenUser{}} <- Certificate.delete_token_user(token_user) do
      send_resp(conn, :no_content, "")
    end
  end
end
