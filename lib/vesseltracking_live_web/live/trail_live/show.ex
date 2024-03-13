defmodule VesseltrackingLiveWeb.TrailLive.Show do
  use VesseltrackingLiveWeb, :live_view

  alias VesseltrackingLive.Track
  alias VesseltrackingLive.Fleets

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    trail = Track.get_trail!(id)
    vessel = Fleets.get_vessels_by_tracking_id(trail.tracking_id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:trail, trail)
     |> assign(:vessel, vessel)}
  end

  defp page_title(:show), do: "Show Trail"
  defp page_title(:edit), do: "Edit Trail"
end
