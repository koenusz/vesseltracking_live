defmodule VesseltrackingLive.Track.Supervisor do
  use DynamicSupervisor
  alias VesseltrackingLive.Track.Trackworker

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(tracking_id) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Trackworker, [tracking_id: tracking_id]}
    )
  end
end
