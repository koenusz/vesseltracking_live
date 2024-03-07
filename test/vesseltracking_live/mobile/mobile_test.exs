defmodule Vesseltracking.MobileTest do
  use Vesseltracking.DataCase

  describe "test file stream" do
    test "file found" do
      %File.Stream{
        raw: true,
        line_or_bytes: 2048,
        modes: [:raw, :read_ahead, :binary],
        path: "config/app-release.apk"
      } == Vesseltracking.Mobile.file_stream()

      Stream.run(Vesseltracking.Mobile.file_stream())
    end

    test "file not found" do
      loc = Application.get_env(:vesseltracking, :apk_location)
      Application.put_env(:vesseltracking, :apk_location, "bla")

      assert %File.Stream{
               raw: true,
               line_or_bytes: 2048,
               modes: [:raw, :read_ahead, :binary],
               path: "bla"
             } == Vesseltracking.Mobile.file_stream()

      assert_raise File.Error, fn -> Stream.run(Vesseltracking.Mobile.file_stream()) end
      Application.put_env(:vesseltracking, :apk_location, loc)
    end
  end
end
