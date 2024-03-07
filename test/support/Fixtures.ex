defmodule Support.Fixtures do
  alias Vesseltracking.Accounts
  alias Vesseltracking.Fleets
  alias Vesseltracking.Track
  alias Vesseltracking.Notifications
  alias Vesseltracking.Chat
  alias Vesseltracking.Chat.ChatRoomMember

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

  def company_fixture(attrs \\ %{}) do
    {:ok, company} =
      attrs
      |> into_if_not_present(%{name: random_string(5)})
      |> Accounts.create_company()

    company
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
    company = company_fixture(attrs)

    {:ok, fleet} =
      attrs
      |> Enum.into(@valid_fleet_attrs)
      |> into_if_not_present(%{company_id: company.id})
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

  def employee_fixture(attrs \\ %{}) do
    company = company_fixture()
    user = user_fixture()

    {:ok, employee} =
      attrs
      |> into_if_not_present(%{company_id: company.id})
      |> into_if_not_present(%{user_id: user.id})
      |> Accounts.create_employee()

    employee
  end

  def authorization_fixture(attrs \\ %{}) do
    user = user_fixture()
    fleet = fleet_fixture()
    employee_fixture(%{user_id: user.id, company_id: fleet.company_id})

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

  def chat_room_member_fixture(attrs \\ %{}) do
    user = user_fixture()
    room = chat_room_fixture()

    {:ok, chat_room_member} =
      Chat.create_chat_room_member(%{chat_room_id: room.id, user_id: user.id} |> Enum.into(attrs))

    chat_room_member
  end

  def chat_room_fixture(attrs \\ %{}) do
    owner = user_fixture()
    member = %{user_id: owner.id, privileges: ChatRoomMember.admin()}
    company = company_fixture()

    attrs =
      attrs
      |> into_if_not_present(%{company_id: company.id, members: [member]})
      |> Enum.into(@chat_room_attrs)

    {:ok, chat_room} = Chat.create_chat_room(attrs)
    chat_room
  end

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
