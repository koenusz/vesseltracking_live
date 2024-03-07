defmodule VesseltrackingLiveWeb.NotificationControllerTest do
  use VesseltrackingLiveWeb.ConnCase

  alias VesseltrackingLive.Notifications
  alias VesseltrackingLive.Notifications.Notification
  alias Plug.Conn
  alias VesseltrackingLiveWeb.NotificationView

  import Support.Fixtures

  @create_attrs %{
    created_on: "2010-04-17T14:00:00Z",
    imei: "some imei",
    is_read: true,
    message: "some message",
    type: "alert"
  }
  @update_attrs %{
    created_on: "2011-05-18T15:01:01Z",
    imei: "some updated imei",
    is_read: false,
    message: "some updated message",
    type: "message"
  }
  @invalid_attrs %{created_on: nil, imei: nil, is_read: nil, message: nil, type: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all notifications", %{conn: conn} do
      conn = get(conn, Routes.notification_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "find by user" do
    setup [:create_notification]

    test "find by user id", %{conn: conn, notification: %Notification{id: id} = notification} do
      conn = Conn.assign(conn, :user_id, notification.user_id)
      conn = get(conn, Routes.notification_path(conn, :find_by_user_id))

      expected = %{
        "id" => id,
        "created_on" => "2010-04-17T14:00:00Z",
        "imei" => "some imei",
        "is_read" => true,
        "message" => "some message",
        "type" => "alert"
      }

      assert json_response(conn, 200)["data"] == [expected]
    end
  end

  describe "create notification" do
    test "renders notification when data is valid", %{conn: conn} do
      user = user_fixture()
      attrs = %{user_id: user.id} |> Enum.into(@create_attrs)

      conn = post(conn, Routes.notification_path(conn, :create), notification: attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.notification_path(conn, :show, id))

      assert %{
               "id" => id,
               "created_on" => "2010-04-17T14:00:00Z",
               "imei" => "some imei",
               "is_read" => true,
               "message" => "some message",
               "type" => "alert"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.notification_path(conn, :create), notification: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update notification" do
    setup [:create_notification]

    test "renders notification when data is valid", %{
      conn: conn,
      notification: %Notification{id: id} = notification
    } do
      conn =
        put(conn, Routes.notification_path(conn, :update, notification),
          notification: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.notification_path(conn, :show, id))

      assert %{
               "id" => id,
               "created_on" => "2011-05-18T15:01:01Z",
               "imei" => "some updated imei",
               "is_read" => false,
               "message" => "some updated message",
               "type" => "message"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, notification: notification} do
      conn =
        put(conn, Routes.notification_path(conn, :update, notification),
          notification: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete notification" do
    setup [:create_notification]

    test "deletes chosen notification", %{conn: conn, notification: notification} do
      conn = delete(conn, Routes.notification_path(conn, :delete, notification))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.notification_path(conn, :show, notification))
      end
    end
  end

  defp create_notification(_) do
    notification = notification_fixture()
    {:ok, notification: notification}
  end
end
