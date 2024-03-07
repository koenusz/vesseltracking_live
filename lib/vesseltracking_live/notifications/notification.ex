defmodule VesseltrackingLive.Notifications.Notification do
  use Ecto.Schema
  import(Ecto.Changeset)

  schema "notifications" do
    field(:created_on, :utc_datetime)
    field(:imei, :string)
    field(:is_read, :boolean, default: false)
    field(:message, :string)
    field(:type, Ecto.Enum, values: [:alert, :message])
    field(:user_id, :id)

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:imei, :message, :type, :is_read, :created_on, :user_id])
    |> validate_required([:imei, :message, :type, :is_read, :created_on, :user_id])
  end
end
