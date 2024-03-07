defmodule VesseltrackingLive.TcpBinaryTest do
  use VesseltrackingLive.ConnCase

  alias VesseltrackingLive.Track.Trackworker

  @tracking_id "test_id"
  @directory ["test", "support", "gtt_testdata"]
  @directip ["Direct IP MsgPack example.sbd"]

  setup do
    port = 9999
    host = "127.0.0.1" |> String.to_charlist()

    # not used but ensures swarm is started
    _track_worker = start_supervised!({Trackworker, @tracking_id})

    {:ok, socket} = :gen_tcp.connect(host, port, active: false)
    {:ok, socket: socket}
  end

  test "should send data", %{socket: socket} do
    filename = Path.join(@directory ++ @directip)
    {:ok, filecontends} = File.read(filename)
    :ok = :gen_tcp.send(socket, filecontends)
    {:ok, reply} = :gen_tcp.recv(socket, 0, 5000)
    assert reply == ~c"OK"
  end
end
