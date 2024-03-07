defmodule VesseltrackingLive.GTTDecoderTest do
  use VesseltrackingLive.DataCase

  @directory ["test", "support", "gtt_testdata"]
  @msgpack ["MsgPack 300234062941290_006556.sbd"]
  @directip ["Direct IP MsgPack example.sbd"]

  alias VesseltrackingLive.GTTDecoder

  describe "messagepack" do
    test "decoding succeeds" do
      filename = Path.join(@directory ++ @msgpack)
      filecontends = File.read!(filename)

      Msgpax.unpack(filecontends)
    end

    test "directIp succeeds" do
      filename = Path.join(@directory ++ @directip)

      filecontends = File.read!(filename)

      {:ok, version, result} = GTTDecoder.decode(filecontends)
      assert version == 1

      {:ok, decoded_payload} = Msgpax.unpack(result[:payload])
      assert decoded_payload[0] == 1
    end

    test "directIp, no location data, succeeds" do
      filename = Path.join(@directory ++ @directip)

      filecontends = File.read!(filename)

      location_removed =
        <<1, 0, 75>> <> binary_part(filecontends, 3, 31) <> binary_part(filecontends, 48, 44)

      {:ok, _version, result} = GTTDecoder.decode(location_removed)

      assert result[:location_data] == nil
      {:ok, decoded_payload} = Msgpax.unpack(result[:payload])
      assert decoded_payload[0] == 1
    end

    test "directIp fails" do
      assert {:error, "expecting length 24937 got 1"} == GTTDecoder.decode(<<"fail">>)
    end

    test "directIp fails, catchall" do
      assert {:error, "invalid format"} == GTTDecoder.decode(<<"f">>)
    end

    test "tracking_id" do
      json_payload = Jason.encode!(%{1 => "0001"})

      payload_size =
        json_payload
        |> String.length()

      appendix = <<0x2A, 0xDA, payload_size::16, json_payload::size(payload_size)-bytes>>

      message =
        "8A000104D257ECEFDF06CA4250F71A07CA40C5D09108CA0000000009CD01610AD1000E1A001BCD0006"

      {:ok, bin} = Base.decode16(message)
      added = bin <> appendix

      {:ok, data} = Msgpax.unpack(added)

      result = Jason.decode!(data[42])
      assert result["1"] == "0001"
    end

    test "example 1" do
      message = "84000104D2525D273906CA4250F47207CA40C642A1"
      {:ok, bin} = Base.decode16(message)
      {:ok, data} = Msgpax.unpack(bin)
      assert data[0] == 1
      assert data[4] == 1_381_836_601
      assert Float.round(data[6], 6) == 52.238716
      assert Float.round(data[7], 6) == 6.195633
    end
  end

  # defp create_payload do
  #   %{
  #     0 => 1,
  #     4 => 1_475_145_695,
  #     6 => 52.241310119628906,
  #     7 => 6.1817097663879395,
  #     8 => 0.0,
  #     9 => 353,
  #     10 => 14,
  #     26 => 0,
  #     27 => 6,
  #     42 => "{\"1\":\"0001\"}"
  #   }
  # end
end
