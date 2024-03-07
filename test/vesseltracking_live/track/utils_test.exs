defmodule Vesseltracking.UtilsTest do
  use Vesseltracking.DataCase

  alias Vesseltracking.Track.Utils
  alias Geo.{MultiPoint, Point}
  @point %Point{coordinates: {15, 30}}
  @multi_point %MultiPoint{coordinates: [{20, 30}, {25, 30}]}

  describe "utils" do
    test "add_point_to_multipoint/2" do
      result = Utils.add_point_to_multipoint(@multi_point, @point)

      assert %MultiPoint{coordinates: [{20, 30}, {25, 30}, {15, 30}]} == result
    end
  end
end
