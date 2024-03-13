defmodule VesseltrackingLiveWeb.VesselLive.Show do
  use VesseltrackingLiveWeb, :live_view

  alias VesseltrackingLive.Fleets

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(fleet_id: nil)}
  end

  @impl true
  def handle_params(%{"id" => id, "fleet_id" => fleet_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:vessel, Fleets.get_vessel!(id))
     |> assign(:fleet_id, fleet_id)}
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
