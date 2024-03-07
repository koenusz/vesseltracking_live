defmodule VesseltrackingLive.Track.Utils do
  alias Geo.{MultiPoint, Point}

  def add_point_to_multipoint(%MultiPoint{} = multi, %Point{} = point) do
    multi.coordinates
    |> (fn coordinates -> %{multi | coordinates: coordinates ++ [point.coordinates]} end).()
  end

  # might not be needed anymore
  # defimpl Jason.Encoder, for: Geo.Point do
  #   def encode(point, options) do
  #     {:ok, encoded} = Geo.JSON.encode(point)
  #     Jason.Encode.map(encoded, options)
  #   end
  # end
end
