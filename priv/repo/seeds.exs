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
alias VesseltrackingLive.Fleets.{Fleet, Vessel}

fleet = VesseltrackingLive.Repo.insert!(%Fleet{name: "testfleet"})

VesseltrackingLive.Repo.insert!(%Vessel{
  name: "test vessel 1",
  tracking_id: "#{System.unique_integer()}",
  fleet_id: fleet.id
})

VesseltrackingLive.Repo.insert!(%Vessel{
  name: "test vessel 2",
  tracking_id: "#{System.unique_integer()}",
  fleet_id: fleet.id
})

VesseltrackingLive.Repo.insert!(%Vessel{
  name: "test vessel 3",
  tracking_id: "#{System.unique_integer()}",
  fleet_id: fleet.id
})

1..4
|> Enum.each(fn _ ->
  %{email: "user#{System.unique_integer()}@example.com", password: "password1234"}
  |> VesseltrackingLive.Accounts.register_user()
end)
