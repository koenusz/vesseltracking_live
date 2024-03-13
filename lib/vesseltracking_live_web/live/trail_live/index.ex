defmodule VesseltrackingLiveWeb.TrailLive.Index do
  use VesseltrackingLiveWeb, :live_view

  alias VesseltrackingLive.Track
  alias VesseltrackingLive.Track.Trail

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :trails, Track.list_trails())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Trail")
    |> assign(:trail, Track.get_trail!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Trail")
    |> assign(:trail, %Trail{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Trails")
    |> assign(:trail, nil)
  end

  @impl true
  def handle_info({VesseltrackingLiveWeb.TrailLive.FormComponent, {:saved, trail}}, socket) do
    {:noreply, stream_insert(socket, :trails, trail)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    trail = Track.get_trail!(id)
    {:ok, _} = Track.delete_trail(trail)

    {:noreply, stream_delete(socket, :trails, trail)}
  end
end
