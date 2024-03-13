defmodule VesseltrackingLiveWeb.FleetLive.FormComponent do
  use VesseltrackingLiveWeb, :live_component

  alias VesseltrackingLive.Fleets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage fleet records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="fleet-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Fleet</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{fleet: fleet} = assigns, socket) do
    changeset = Fleets.change_fleet(fleet)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"fleet" => fleet_params}, socket) do
    changeset =
      socket.assigns.fleet
      |> Fleets.change_fleet(fleet_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"fleet" => fleet_params}, socket) do
    save_fleet(socket, socket.assigns.action, fleet_params)
  end

  defp save_fleet(socket, :edit, fleet_params) do
    case Fleets.update_fleet(socket.assigns.fleet, fleet_params) do
      {:ok, fleet} ->
        notify_parent({:saved, fleet})

        {:noreply,
         socket
         |> put_flash(:info, "Fleet updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_fleet(socket, :new, fleet_params) do
    case Fleets.create_fleet(fleet_params) do
      {:ok, fleet} ->
        notify_parent({:saved, fleet})

        {:noreply,
         socket
         |> put_flash(:info, "Fleet created successfully")
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
