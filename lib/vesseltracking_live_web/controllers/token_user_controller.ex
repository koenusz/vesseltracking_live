defmodule VesseltrackingLiveWeb.TokenUserController do
  use VesseltrackingLiveWeb, :controller

  alias VesseltrackingLive.Certificate
  alias VesseltrackingLive.ChallengeAgent

  action_fallback VesseltrackingLiveWeb.FallbackController

  def request_access(conn, %{
        "user_name" => user_name,
        "pub_key" => pem,
        "signature" => signature
      }) do
    if Certificate.verify(pem, signature, pem) do
      %{
        comment: "",
        username: user_name,
        pubkey: pem,
        approved?: false,
        created_at: DateTime.utc_now(),
        expires_at: DateTime.utc_now() |> DateTime.add(365, :day)
      }
      |> Certificate.create_token_user()

      json(conn, %{msg: "request received"})
    else
      {:error, :unauthorized}
    end
  end

  def login(conn, %{token_user_id: token_user_id}) do
    pub_key =
      Certificate.get_token_user!(token_user_id).pub_key
      |> :public_key.pem_decode()

    random = :crypto.strong_rand_bytes(8)

    ChallengeAgent.start_link(%{token_user_id: token_user_id, random: random})

    challenge =
      random
      |> :public_key.encrypt_public(pub_key)

    send_resp(conn, 200, challenge)
  end

  def challenge(conn, %{token_user_id: token_user_id, decrypted: decrypted}) do
    if(ChallengeAgent.challenge(token_user_id, decrypted)) do
      # create a proper login token

      send_resp(conn, 200, "login_token")
    end

    send_resp(conn, 401, "")
  end
end
