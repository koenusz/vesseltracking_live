defmodule VesseltrackingLiveWeb.AuthorizationLive.FormComponent do
  use VesseltrackingLiveWeb, :live_component

  alias VesseltrackingLive.Fleets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage authorization records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="authorization-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:user_id]}
          type="select"
          label="Users"
          options={@users |> Enum.map(fn user -> {:"#{user.email}", user.id} end)}
        />
        <.input field={@form[:fleet_id]} type="hidden" value={"#{assigns.authorization.fleet_id}"} />
        <:actions>
          <.button phx-disable-with="Saving...">Save Authorization</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{authorization: authorization} = assigns, socket) do
    changeset = Fleets.change_authorization(authorization)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"authorization" => authorization_params}, socket) do
    changeset =
      socket.assigns.authorization
      |> Fleets.change_authorization(authorization_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"authorization" => authorization_params}, socket) do
    save_authorization(socket, socket.assigns.action, authorization_params)
  end

  defp save_authorization(socket, :edit, authorization_params) do
    case Fleets.update_authorization(socket.assigns.authorization, authorization_params) do
      {:ok, authorization} ->
        notify_parent({:saved, authorization})

        {:noreply,
         socket
         |> put_flash(:info, "Authorization updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_authorization(socket, :new, authorization_params) do
    case Fleets.create_authorization(authorization_params) do
      {:ok, authorization} ->
        notify_parent({:saved, authorization})

        {:noreply,
         socket
         |> put_flash(:info, "Authorization created successfully")
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
