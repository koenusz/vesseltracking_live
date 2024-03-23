defmodule VesseltrackingLiveWeb.VesselLive.FormComponent do
  use VesseltrackingLiveWeb, :live_component

  alias VesseltrackingLive.Fleets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage vessel records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="vessel-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input
          field={@form[:tracking_id]}
          type="select"
          options={@tracking_id_options}
          label="Tracking"
        />
        <.input field={@form[:fleet_id]} type="select" options={@fleet_options} label="Fleet" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Vessel</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{vessel: vessel} = assigns, socket) do
    changeset = Fleets.change_vessel(vessel)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"vessel" => vessel_params}, socket) do
    changeset =
      socket.assigns.vessel
      |> Fleets.change_vessel(vessel_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"vessel" => vessel_params}, socket) do
    save_vessel(socket, socket.assigns.action, vessel_params)
  end

  defp save_vessel(socket, :edit, vessel_params) do
    case Fleets.update_vessel(socket.assigns.vessel, vessel_params) do
      {:ok, vessel} ->
        notify_parent({:saved, vessel})

        {:noreply,
         socket
         |> put_flash(:info, "Vessel updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_vessel(socket, :new, vessel_params) do
    case Fleets.create_vessel(vessel_params) do
      {:ok, vessel} ->
        notify_parent({:saved, vessel})

        {:noreply,
         socket
         |> put_flash(:info, "Vessel created successfully")
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
