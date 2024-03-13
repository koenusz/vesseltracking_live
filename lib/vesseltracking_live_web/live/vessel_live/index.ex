defmodule VesseltrackingLiveWeb.VesselLive.Index do
  use VesseltrackingLiveWeb, :live_view

  alias VesseltrackingLive.Fleets
  alias VesseltrackingLive.Fleets.Vessel

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :vessels, Fleets.list_vessels())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Vessel")
    |> assign(:vessel, Fleets.get_vessel!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Vessel")
    |> assign(:vessel, %Vessel{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Vessels")
    |> assign(:vessel, nil)
  end

  @impl true
  def handle_info({VesseltrackingLiveWeb.VesselLive.FormComponent, {:saved, vessel}}, socket) do
    {:noreply, stream_insert(socket, :vessels, vessel)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    vessel = Fleets.get_vessel!(id)
    {:ok, _} = Fleets.delete_vessel(vessel)

    {:noreply, stream_delete(socket, :vessels, vessel)}
  end
end
