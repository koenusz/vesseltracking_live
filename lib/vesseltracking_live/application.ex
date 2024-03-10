defmodule VesseltrackingLive.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      VesseltrackingLiveWeb.Telemetry,
      VesseltrackingLive.Repo,
      {DNSCluster,
       query: Application.get_env(:vesseltracking_live, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: VesseltrackingLive.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: VesseltrackingLive.Finch},
      # Start a worker by calling: VesseltrackingLive.Worker.start_link(arg)
      # {VesseltrackingLive.Worker, arg},
      # Start to serve requests, typically the last entry
      VesseltrackingLiveWeb.Endpoint,
      VesseltrackingLive.Track.Supervisor,
      {Registry, keys: :unique, name: VesseltrackingLive.Track.TrackRegistry}
      # VesseltrackingLive.DirectIpWorker
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VesseltrackingLive.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VesseltrackingLiveWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
