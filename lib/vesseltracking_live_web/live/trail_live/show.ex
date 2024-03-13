defmodule VesseltrackingLiveWeb.TrailLive.Show do
  use VesseltrackingLiveWeb, :live_view

  alias VesseltrackingLive.Track

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:trail, Track.get_trail!(id))}
  end

  defp page_title(:show), do: "Show Trail"
  defp page_title(:edit), do: "Edit Trail"
end
