defmodule VesseltrackingLive.FleetsFixtures do
  alias VesseltrackingLive.Fleets

  @valid_fleet_attrs %{name: "some name"}

  def fleet_fixture(attrs \\ %{}) do
    {:ok, fleet} =
      attrs
      |> Enum.into(@valid_fleet_attrs)
      |> Fleets.create_fleet()

    fleet
  end

  def vessel_fixture(attrs \\ %{}) do
    {:ok, vessel} =
      attrs
      |> Enum.into(%{
        name: "some name",
        tracking_id: :crypto.strong_rand_bytes(8) |> Base.encode64()
      })
      |> Fleets.create_vessel()

    vessel
  end

  def authorization_fixture(attrs \\ %{}) do
    {:ok, authorization} =
      attrs
      |> Enum.into(%{})
      |> Fleets.create_authorization()

    authorization
  end
end
