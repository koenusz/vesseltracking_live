defmodule VesseltrackingLive.CertificateFixtures do
  alias VesseltrackingLive.Certificate.TokenUser

  @moduledoc """
  This module defines test helpers for creating
  entities via the `VesseltrackingLive.Certificate` context.
  """

  @doc """
  Generate a token_user.
  """
  def token_user_fixture(attrs \\ %{}) do
    # 1024 for speed during test in prod should be 4096
    pub = TokenUser.generate_private_key(1024) |> TokenUser.pem_encoded_public_key()

    {:ok, token_user} =
      attrs
      |> Enum.into(%{
        approved?: true,
        comment: "some comment",
        created_at: ~U[2024-03-16 10:04:00Z],
        expires_at: ~U[2024-03-16 10:04:00Z],
        pubkey: pub,
        username: "some username"
      })
      |> VesseltrackingLive.Certificate.create_token_user()

    token_user
  end
end
