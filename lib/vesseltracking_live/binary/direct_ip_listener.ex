defmodule VesseltrackingLive.Listeners.DirectIpProtocol do
  def child_spec(opts) do
    :ranch.child_spec(__MODULE__, :ranch_tcp, opts, VesseltrackingLive.DirectIpProtocol, [])
  end
end
