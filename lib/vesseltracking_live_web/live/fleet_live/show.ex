defmodule VesseltrackingLiveWeb.FleetLive.Show do
  use VesseltrackingLiveWeb, :live_view

  alias VesseltrackingLive.Fleets

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:fleet, Fleets.get_fleet!(id))}
  end

  @impl true
  def handle_event("delete_vessel", %{"id" => id}, socket) do
    vessel = Fleets.get_vessel!(id)
    {:ok, _} = Fleets.delete_vessel(vessel)

    {:noreply, stream_delete(socket, :vessels, vessel)}
  end

  defp page_title(:show), do: "Show Fleet"
  defp page_title(:edit), do: "Edit Fleet"
end
