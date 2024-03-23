defmodule VesseltrackingLiveWeb.VesselLive.Show do
  use VesseltrackingLiveWeb, :live_view

  alias VesseltrackingLive.Fleets
  alias VesseltrackingLive.Track

  @impl true
  def mount(_params, _session, socket) do
    options =
      Fleets.list_fleets()
      |> Enum.map(fn fleet -> {:"#{fleet.name}", fleet.id} end)

    tracking_id_options =
      Track.list_unclaimed_trails()
      |> Enum.map(fn trail -> {:"#{trail.tracking_id}", trail.tracking_id} end)

    socket =
      socket
      |> assign(fleet_options: options)
      |> assign(tracking_id_options: tracking_id_options)
      |> assign(return_fleet: nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "fleet_id" => fleet_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:vessel, Fleets.get_vessel!(id))
     |> assign(:return_fleet, Fleets.get_fleet!(fleet_id))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:vessel, Fleets.get_vessel!(id))}
  end

  defp page_title(:show), do: "Show Vessel"
  defp page_title(:edit), do: "Edit Vessel"
  defp page_title(:fleet), do: "Edit Vessel in Fleet"
end
