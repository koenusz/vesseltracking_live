defmodule Support.Fixtures do
  alias VesseltrackingLive.Accounts
  alias VesseltrackingLive.Fleets
  alias VesseltrackingLive.Track
  alias VesseltrackingLive.Notifications
  alias VesseltrackingLive.Chat
  alias VesseltrackingLive.Chat.ChatRoomMember

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
    user = user_fixture()

    {:ok, notification} =
      attrs
      |> into_if_not_present(%{user_id: user.id})
      |> Enum.into(@valid_notification_alert)
      |> Notifications.create_notification()

    notification
  end

  @valid_user_attrs %{
    bio: "some bio",
    image: "some image",
    password: "some password_hash",
    username: "some username",
    administrator: false
  }

  def user_fixture(attrs \\ %{}) do
    email = random_string(7) <> "@test.com"

    {:ok, user} =
      attrs
      |> Enum.into(%{email: email})
      |> Enum.into(@valid_user_attrs)
      |> Accounts.create_user()

    user
  end

  def admin_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_user_attrs)
      |> Accounts.create_admin_user()

    user
  end

  @valid_fleet_attrs %{name: "some name"}

  def fleet_fixture(attrs \\ %{}) do
    {:ok, fleet} =
      attrs
      |> Enum.into(@valid_fleet_attrs)
      |> Fleets.create_fleet()

    fleet
  end

  def vessel_fixture(attrs \\ %{}) do
    fleet = fleet_fixture()

    {:ok, vessel} =
      attrs
      |> into_if_not_present(%{
        name: "some name",
        fleet_id: fleet.id,
        tracking_id: random_string(15)
      })
      |> Fleets.create_vessel()

    vessel
  end

  def authorization_fixture(attrs \\ %{}) do
    user = user_fixture()
    fleet = fleet_fixture()

    {:ok, authorization} =
      attrs
      |> Enum.into(%{user_id: user.id, fleet_id: fleet.id})
      |> Fleets.create_authorization()

    authorization
  end

  def trail_fixture(attrs \\ %{}) do
    {:ok, trail} =
      attrs
      |> into_if_not_present(%{
        day: Date.utc_today(),
        steps: [],
        tracking_id: random_string(15)
      })
      |> Track.create_trail()

    trail
  end

  @chat_room_attrs %{
    name: "some name",
    members: []
  }

  defp into_if_not_present(enum, item) do
    case Enum.member?(enum, item) do
      true -> enum
      false -> Enum.into(enum, item)
    end
  end

  defp random_string(size) do
    :crypto.strong_rand_bytes(size) |> Base.url_encode64() |> binary_part(0, size)
  end
end
