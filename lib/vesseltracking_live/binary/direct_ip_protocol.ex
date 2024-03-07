defmodule VesseltrackingLive.DirectIpProtocol do
  use GenServer
  alias VesseltrackingLive.GTTDecoder
  alias VesseltrackingLive.{Track.Step, Track}

  @behaviour :ranch_protocol

  def start_link(ref, socket, transport, _opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, socket, transport])
    {:ok, pid}
  end

  def init(args) do
    {:ok, args}
  end

  def init(ref, socket, transport) do
    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [{:active, true}])
    :gen_server.enter_loop(__MODULE__, [], %{socket: socket, transport: transport})
  end

  def handle_info({:tcp, socket, data}, state = %{socket: socket, transport: transport}) do
    %{header: header, payload: payload} = unpack_body(data)

    %{header: header, payload: payload}
    |> direct_ip_step()
    |> store_and_forward_step(header.imei)

    :ok = transport.send(socket, "OK")
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state = %{socket: socket, transport: transport}) do
    transport.close(socket)
    {:stop, :normal, state}
  end

  defp unpack_body(body) do
    case GTTDecoder.decode(body) do
      {:ok, _version, %{header: header, payload: payload}} ->
        %{header: header, payload: Msgpax.unpack!(payload)}

      {:ok, _version, %{header: header, location_data: location_data, payload: payload}} ->
        %{header: header, location_data: location_data, payload: Msgpax.unpack!(payload)}
    end
  end

  def direct_ip_step(%{header: header, payload: payload}) do
    point = %Geo.Point{coordinates: {payload[7], payload[6]}}
    timestamp = DateTime.from_unix!(payload[4], :second)

    %Step{}
    |> add_to_step(:origin_timestamp, timestamp)
    |> add_to_step(:point, point)
    |> add_to_step(:call_data_record, header.cdr)
    |> add_to_step(:session_status, header.session_status)
    |> add_to_step(:mobile_originated_message_number, header.momsn)
    |> add_to_step(:mobile_terminated_message_number, header.mtmsn)
    |> add_to_step(:speed, payload[8])
    |> add_to_step(:heading, payload[9])
    |> add_to_step(:altitude, payload[10])
    |> add_to_step(:emergency, payload[24] |> emergency_code_to_string)
    |> add_to_step(:sensor1, payload[26])
    |> add_to_step(:sensor2, payload[27])
    |> add_to_step(:analogue_mask, payload[34])
    |> add_to_step(:analogue_data, payload[35])
    |> add_to_step(:text_message, payload[42])
  end

  defp emergency_code_to_string(code) do
    case code do
      nil -> nil
      0 -> "No Emergency"
      1 -> "Emergency"
      2 -> "Cancelled"
    end
  end

  defp add_to_step(step, key, value) do
    case value do
      nil -> step
      _ -> Map.put(step, key, value)
    end
  end

  defp store_and_forward_step(step, tracking_id) do
    {:ok, _} = Track.add_step(tracking_id, step)

    VesseltrackingWeb.Endpoint.broadcast!(
      "vessel:" <> tracking_id,
      "message",
      %{"body" => step}
    )
  end
end
