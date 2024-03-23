# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     VesseltrackingLive.Repo.insert!(%VesseltrackingLive.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias VesseltrackingLive.Fleets
alias VesseltrackingLive.Fleets.{Fleet, Vessel}
alias VesseltrackingLive.Track
alias VesseltrackingLive.Track.Step

fleet = VesseltrackingLive.Repo.insert!(%Fleet{name: "testfleet"})

1..3
|> Enum.each(fn i ->
  %{
    name: "test vessel #{i}",
    tracking_id: :crypto.strong_rand_bytes(8) |> Base.url_encode64(),
    fleet_id: fleet.id
  }
  |> Fleets.create_vessel()
end)

1..4
|> Enum.each(fn _ ->
  %{email: "user#{System.unique_integer()}@example.com", password: "password1234"}
  |> VesseltrackingLive.Accounts.register_user()
end)

alias VesseltrackingLive.Certificate.TokenUser

1..4
|> Enum.each(fn _ ->
  pub = TokenUser.generate_private_key(1024) |> TokenUser.pem_encoded_public_key()

  %{
    approved?: true,
    comment: "some comment",
    created_at: ~U[2024-03-16 10:04:00Z],
    expires_at: ~U[2024-03-16 10:04:00Z],
    pubkey: pub,
    username: "some username"
  }
  |> VesseltrackingLive.Certificate.create_token_user()
end)

step1 = %Geo.Point{coordinates: {20, 30}} |> Step.from_point()
step2 = %Geo.Point{coordinates: {20, 31}} |> Step.from_point()
step3 = %Geo.Point{coordinates: {20, 32}} |> Step.from_point()

1..20
|> Enum.each(fn _ ->
  %{
    day: Date.utc_today(),
    steps: [step1, step2, step3],
    tracking_id: :crypto.strong_rand_bytes(8) |> Base.url_encode64()
  }
  |> Track.create_trail()
end)
