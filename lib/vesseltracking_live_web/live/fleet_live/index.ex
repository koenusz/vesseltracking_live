defmodule VesseltrackingLiveWeb.FleetLive.Index do
  use VesseltrackingLiveWeb, :live_view

  alias VesseltrackingLive.Fleets
  alias VesseltrackingLive.Fleets.Fleet

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :fleets, Fleets.list_fleets())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Fleet")
    |> assign(:fleet, Fleets.get_fleet!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Fleet")
    |> assign(:fleet, %Fleet{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Fleets")
    |> assign(:fleet, nil)
  end

  @impl true
  def handle_info({VesseltrackingLiveWeb.FleetLive.FormComponent, {:saved, fleet}}, socket) do
    {:noreply, stream_insert(socket, :fleets, fleet)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    fleet = Fleets.get_fleet!(id)
    {:ok, _} = Fleets.delete_fleet(fleet)

    {:noreply, stream_delete(socket, :fleets, fleet)}
  end
end
