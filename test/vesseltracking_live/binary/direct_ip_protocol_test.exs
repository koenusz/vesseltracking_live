defmodule VesseltrackingLive.Binary.DirectIpProtocolTest do
  use VesseltrackingLive.DataCase, async: true

  alias VesseltrackingLive.Track.Step
  alias VesseltrackingLive.DirectIpProtocol

  describe "payload To Step" do
    test "all fields" do
      header = %{
        cdr: 123,
        session_status: 200,
        momsn: 5_446_116,
        mtmsn: 5_664_654
      }

      payload = %{
        0 => 1,
        4 => 1_476_695_460,
        6 => 52.24137496948242,
        7 => 6.181759834289551,
        8 => 0.0,
        9 => 245,
        10 => 12,
        24 => Enum.random([0, 1, 2]),
        26 => 0,
        27 => 1,
        42 => "test message"
      }

      step =
        %{header: header, payload: payload}
        |> DirectIpProtocol.direct_ip_step()

      assert %Step{
               altitude: 12,
               sensor1: 0,
               sensor2: 1,
               text_message: "test message"
             } = step
    end
  end
end
