defmodule VesseltrackingLiveWeb.TokenUserControllerTest do
  use VesseltrackingLiveWeb.ConnCase

  import VesseltrackingLive.CertificateFixtures

  alias VesseltrackingLive.Certificate.TokenUser
  alias VesseltrackingLive.Certificate

  @user_name "user_name"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "request Access", %{conn: conn} do
    pr_key = Certificate.generate_private_key(1024)

    pem =
      pr_key
      |> Certificate.pem_encoded_public_key()

    digest = Certificate.digest(pem, @user_name)

    signature = Certificate.sign(digest, pr_key)

    conn =
      post(conn, ~p"/api/request_access", %{
        user_name: @user_name,
        pub_key: pem,
        signature: signature,
        digest: digest
      })

    assert %{"msg" => "request received"} == json_response(conn, 200)
  end

  test "request Access with incorrect digest", %{conn: conn} do
    pr_key = Certificate.generate_private_key(1024)

    pem =
      pr_key
      |> Certificate.pem_encoded_public_key()

    digest = Certificate.digest(pem, @user_name)

    signature = Certificate.sign(digest, pr_key)

    conn =
      post(conn, ~p"/api/request_access", %{
        user_name: "incorrect",
        pub_key: pem,
        signature: signature,
        digest: digest
      })

    assert json_response(conn, 401)
  end
end
