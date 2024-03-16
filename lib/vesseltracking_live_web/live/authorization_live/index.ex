defmodule VesseltrackingLiveWeb.AuthorizationLive.Index do
  alias VesseltrackingLive.Accounts
  use VesseltrackingLiveWeb, :live_view

  alias VesseltrackingLive.Fleets
  alias VesseltrackingLive.Fleets.Authorization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:users, Accounts.list_users())}
  end

  @impl true
  def handle_params(%{"fleet_id" => fleet_id} = params, _url, socket) do
    auths = Fleets.list_authorizations_by_fleet_id(fleet_id)
    users = socket.assigns.users -- (auths |> Enum.map(fn auth -> auth.user end))

    {:noreply,
     socket
     |> assign(fleet: Fleets.get_fleet!(fleet_id))
     |> assign(users: users)
     |> apply_action(socket.assigns.live_action, params)
     |> stream(:authorizations, auths)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Authorization")
    |> assign(:authorization, %Authorization{fleet_id: socket.assigns.fleet.id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Authorizations")
    |> assign(:authorization, nil)
  end

  @impl true
  def handle_info(
        {VesseltrackingLiveWeb.AuthorizationLive.FormComponent, {:saved, authorization}},
        socket
      ) do
    {:noreply, stream_insert(socket, :authorizations, authorization)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    authorization = Fleets.get_authorization!(id)
    {:ok, _} = Fleets.delete_authorization(authorization)

    {:noreply, stream_delete(socket, :authorizations, authorization)}
  end
end
