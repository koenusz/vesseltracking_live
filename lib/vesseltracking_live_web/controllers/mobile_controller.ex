defmodule VesseltrackingLiveWeb.MobileController do
  use VesseltrackingLiveWeb, :controller

  def download_mobile_archive(conn, _params) do
    try do
      VesseltrackingLive.Mobile.file_stream()
      |> Enum.into(
        conn
        |> put_resp_content_type("application/vnd.android.package-archive")
        |> put_resp_header(
          "content-disposition",
          "attachment; filename=com.zona_tracking.App.apk"
        )
        |> send_chunked(200)
      )
    rescue
      _ in File.Error ->
        conn
        |> json(%{error: "app not avaiable"})
    end
  end
end
