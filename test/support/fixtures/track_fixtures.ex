defmodule VesseltrackingLive.TrackFixtures do
  alias VesseltrackingLive.Track

  def trail_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      day: Date.utc_today(),
      steps: [],
      tracking_id: :crypto.strong_rand_bytes(8) |> Base.url_encode64()
    })
    |> Track.create_trail()
  end
end
