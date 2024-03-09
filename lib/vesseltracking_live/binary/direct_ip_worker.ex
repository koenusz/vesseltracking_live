defmodule VesseltrackingLive.DirectIpWorker do
  require Logger

  def start_link do
    port = 9999
    # opts = [{:port, port}]
    Logger.info("Starting listener at port #{port} ")

    # {:ok, _} =
    #   :ranch.start_listener(
    #     :gtt_binary,
    #     100,
    #     :ranch_tcp,
    #     opts,
    #     VesseltrackingLive.DirectIpProtocol,
    #     []
    #   )
  end
end
