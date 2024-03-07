defmodule Vesseltracking.PointAdapter do
  def translate(point) do
    case point do
      %Geo.Point{} ->
        {:ok, point}

      %{"point" => %Geo.Point{}} ->
        {:ok, point["point"]}

      %{"ele" => _ele, "lat" => lat, "lon" => lon, "name" => _name} ->
        {:ok, %Geo.Point{coordinates: {lon, lat}}}

      _ ->
        {:error, point}
    end
  end
end
