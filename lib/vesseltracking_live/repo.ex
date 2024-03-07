defmodule VesseltrackingLive.Repo do
  use Ecto.Repo,
    otp_app: :vesseltracking_live,
    adapter: Ecto.Adapters.Postgres
end
