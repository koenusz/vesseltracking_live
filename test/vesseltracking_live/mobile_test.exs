defmodule VesseltrackingLive.MobileTest do
  use VesseltrackingLive.DataCase

  describe "test file stream" do
    test "file found" do
      %File.Stream{
        raw: true,
        line_or_bytes: 2048,
        modes: [:raw, :read_ahead, :binary],
        path: "config/app-release.apk"
      } == VesseltrackingLive.Mobile.file_stream()

      Stream.run(VesseltrackingLive.Mobile.file_stream())
    end

    test "file not found" do
      loc = Application.get_env(:vesseltracking_live, :apk_location)
      Application.put_env(:vesseltracking_live, :apk_location, "bla")

      assert %File.Stream{
               raw: true,
               line_or_bytes: 2048,
               modes: [:raw, :read_ahead, :binary],
               path: "bla"
             } == VesseltrackingLive.Mobile.file_stream()

      assert_raise File.Error, fn -> Stream.run(VesseltrackingLive.Mobile.file_stream()) end
      Application.put_env(:vesseltracking_live, :apk_location, loc)
    end
  end
end
