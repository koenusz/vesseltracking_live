defmodule VesseltrackingLive.DirectIpSupervisor do
  use Supervisor
  require Logger

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  @impl true
  def init(_) do
    port = Application.fetch_env!(:vesseltracking_live, :directIpListenerPort)
    Logger.info("Starting listener at port #{port} ")

    children = [
      {VesseltrackingLive.Listeners.DirectIpProtocol, [{:port, port}]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
