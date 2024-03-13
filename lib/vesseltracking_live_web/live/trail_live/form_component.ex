defmodule VesseltrackingLiveWeb.TrailLive.FormComponent do
  use VesseltrackingLiveWeb, :live_component

  alias VesseltrackingLive.Track

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage trail records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="trail-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:day]} type="date" label="Day" />
        <.input
          field={@form[:steps]}
          type="select"
          multiple
          label="Steps"
          options={[]}
        />
        <.input field={@form[:tracking_id]} type="text" label="Tracking" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Trail</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{trail: trail} = assigns, socket) do
    changeset = Track.change_trail(trail)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"trail" => trail_params}, socket) do
    changeset =
      socket.assigns.trail
      |> Track.change_trail(trail_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"trail" => trail_params}, socket) do
    save_trail(socket, socket.assigns.action, trail_params)
  end

  defp save_trail(socket, :edit, trail_params) do
    case Track.update_trail(socket.assigns.trail, trail_params) do
      {:ok, trail} ->
        notify_parent({:saved, trail})

        {:noreply,
         socket
         |> put_flash(:info, "Trail updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_trail(socket, :new, trail_params) do
    case Track.create_trail(trail_params) do
      {:ok, trail} ->
        notify_parent({:saved, trail})

        {:noreply,
         socket
         |> put_flash(:info, "Trail created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
