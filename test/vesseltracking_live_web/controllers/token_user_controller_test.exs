defmodule VesseltrackingLiveWeb.TokenUserControllerTest do
  use VesseltrackingLiveWeb.ConnCase

  import VesseltrackingLive.CertificateFixtures

  alias VesseltrackingLive.Certificate.TokenUser

  @create_attrs %{
    comment: "some comment",
    username: "some username",
    pubkey: "some pubkey",
    approved?: true,
    created_at: ~U[2024-03-16 10:04:00Z],
    expires_at: ~U[2024-03-16 10:04:00Z]
  }
  @update_attrs %{
    comment: "some updated comment",
    username: "some updated username",
    pubkey: "some updated pubkey",
    approved?: false,
    created_at: ~U[2024-03-17 10:04:00Z],
    expires_at: ~U[2024-03-17 10:04:00Z]
  }
  @invalid_attrs %{comment: nil, username: nil, pubkey: nil, approved?: nil, created_at: nil, expires_at: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all token_users", %{conn: conn} do
      conn = get(conn, ~p"/api/token_users")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create token_user" do
    test "renders token_user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/token_users", token_user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/token_users/#{id}")

      assert %{
               "id" => ^id,
               "approved?" => true,
               "comment" => "some comment",
               "created_at" => "2024-03-16T10:04:00Z",
               "expires_at" => "2024-03-16T10:04:00Z",
               "pubkey" => "some pubkey",
               "username" => "some username"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/token_users", token_user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update token_user" do
    setup [:create_token_user]

    test "renders token_user when data is valid", %{conn: conn, token_user: %TokenUser{id: id} = token_user} do
      conn = put(conn, ~p"/api/token_users/#{token_user}", token_user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/token_users/#{id}")

      assert %{
               "id" => ^id,
               "approved?" => false,
               "comment" => "some updated comment",
               "created_at" => "2024-03-17T10:04:00Z",
               "expires_at" => "2024-03-17T10:04:00Z",
               "pubkey" => "some updated pubkey",
               "username" => "some updated username"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, token_user: token_user} do
      conn = put(conn, ~p"/api/token_users/#{token_user}", token_user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete token_user" do
    setup [:create_token_user]

    test "deletes chosen token_user", %{conn: conn, token_user: token_user} do
      conn = delete(conn, ~p"/api/token_users/#{token_user}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/token_users/#{token_user}")
      end
    end
  end

  defp create_token_user(_) do
    token_user = token_user_fixture()
    %{token_user: token_user}
  end
end
