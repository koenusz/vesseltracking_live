defmodule Support.Fixtures do
  alias VesseltrackingLive.Notifications

  alias VesseltrackingLive.AccountsFixtures

  @valid_notification_alert %{
    created_on: "2010-04-17T14:00:00Z",
    imei: "some imei",
    is_read: true,
    message: "some message",
    type: "alert"
  }
  def valid_notification_alert, do: @valid_notification_alert

  @valid_notification_message %{
    created_on: "2010-04-17T14:00:00Z",
    imei: "some imei",
    is_read: true,
    message: "some message",
    type: "message"
  }
  def valid_notification_message, do: @valid_notification_message

  def notification_fixture(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture()

    {:ok, notification} =
      attrs
      |> into_if_not_present(%{user_id: user.id})
      |> Enum.into(@valid_notification_alert)
      |> Notifications.create_notification()

    notification
  end

  defp into_if_not_present(enum, item) do
    case Enum.member?(enum, item) do
      true -> enum
      false -> Enum.into(enum, item)
    end
  end
end
