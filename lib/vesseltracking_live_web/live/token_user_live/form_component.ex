defmodule VesseltrackingLiveWeb.TokenUserLive.FormComponent do
  use VesseltrackingLiveWeb, :live_component

  alias VesseltrackingLive.Certificate

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage token_user records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="token_user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:username]} type="text" label="Username" disabled={true} />
        <.input field={@form[:pubkey]} type="hidden" disabled={true} />
        <.input field={@form[:approved?]} type="checkbox" label="Approved?" />
        <.input field={@form[:created_at]} type="datetime-local" label="Created at" disabled={true} />
        <.input field={@form[:expires_at]} type="datetime-local" label="Expires at" disabled={true} />
        <.input field={@form[:comment]} type="text" label="Comment" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Token user</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{token_user: token_user} = assigns, socket) do
    changeset = Certificate.change_token_user(token_user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"token_user" => token_user_params}, socket) do
    changeset =
      socket.assigns.token_user
      |> Certificate.change_token_user(token_user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"token_user" => token_user_params}, socket) do
    save_token_user(socket, socket.assigns.action, token_user_params)
  end

  defp save_token_user(socket, :edit, token_user_params) do
    case Certificate.update_token_user(socket.assigns.token_user, token_user_params) do
      {:ok, token_user} ->
        notify_parent({:saved, token_user})

        {:noreply,
         socket
         |> put_flash(:info, "Token user updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_token_user(socket, :new, token_user_params) do
    case Certificate.create_token_user(token_user_params) do
      {:ok, token_user} ->
        notify_parent({:saved, token_user})

        {:noreply,
         socket
         |> put_flash(:info, "Token user created successfully")
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
