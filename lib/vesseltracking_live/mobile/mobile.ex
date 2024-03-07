defmodule VesseltrackingLive.Mobile do
  def file_stream do
    Application.fetch_env!(:vesseltracking_live, :apk_location)
    |> File.stream!([], 2048)
  end
end
