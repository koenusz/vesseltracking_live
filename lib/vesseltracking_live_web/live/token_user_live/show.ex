defmodule VesseltrackingLiveWeb.TokenUserLive.Show do
  use VesseltrackingLiveWeb, :live_view

  alias VesseltrackingLive.Certificate

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:token_user, Certificate.get_token_user!(id))}
  end

  defp page_title(:show), do: "Show Token user"
  defp page_title(:edit), do: "Edit Token user"
end
