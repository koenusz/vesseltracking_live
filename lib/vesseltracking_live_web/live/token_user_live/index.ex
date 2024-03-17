defmodule VesseltrackingLiveWeb.TokenUserLive.Index do
  use VesseltrackingLiveWeb, :live_view

  alias VesseltrackingLive.Certificate
  alias VesseltrackingLive.Certificate.TokenUser

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :token_users, Certificate.list_token_users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Token user")
    |> assign(:token_user, Certificate.get_token_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Token user")
    |> assign(:token_user, %TokenUser{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Token users")
    |> assign(:token_user, nil)
  end

  @impl true
  def handle_info({VesseltrackingLiveWeb.TokenUserLive.FormComponent, {:saved, token_user}}, socket) do
    {:noreply, stream_insert(socket, :token_users, token_user)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    token_user = Certificate.get_token_user!(id)
    {:ok, _} = Certificate.delete_token_user(token_user)

    {:noreply, stream_delete(socket, :token_users, token_user)}
  end
end
