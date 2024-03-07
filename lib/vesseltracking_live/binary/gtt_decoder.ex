defmodule VesseltrackingLive.GTTDecoder do
  import Logger

  defmodule MO_Header do
    @enforce_keys :imei
    defstruct [:cdr, :imei, :session_status, :momsn, :mtmsn, :time_of_session]
  end

  defmodule MT_Header do
    @enforce_keys :imei
    defstruct [:client_message_id, :imei, :disposition_flags]
  end

  defmodule LocationData do
    @enforce_keys [:lattitude, :longitude, :cep]
    defstruct [:lattitude, :longitude, :cep]
  end

  defmodule Confirmation do
    @enforce_keys [:client_message_id, :imei, :auto_id, :message_status]
    defstruct [:client_message_id, :imei, :auto_id, :message_status]
  end

  def decode(<<version::8, length::16, message::size(length)-bytes>>) do
    debug("message")
    result = decode_slice(message, %{})
    {:ok, version, result}
  end

  def decode(<<_version::8, length::16, message::binary>>) do
    {:error, "expecting length #{length} got #{byte_size(message)}"}
  end

  def decode(_) do
    {:error, "invalid format"}
  end

  defp decode_slice(<<0x01, length::16, header::size(length)-bytes, rest::binary>>, result) do
    debug("header")

    decoded = decode_mo_header(header)

    result =
      result
      |> Map.put(:header, decoded)

    decode_continue(rest, result)
  end

  defp decode_slice(<<0x02, length::16, payload::size(length)-bytes, rest::binary>>, result) do
    debug("payload")

    result =
      result
      |> Map.put(:payload, payload)

    decode_continue(rest, result)
  end

  defp decode_slice(<<0x03, length::16, location_data::size(length)-bytes, rest::binary>>, result) do
    debug("location_data")
    decoded = decode_location_data(location_data)

    result =
      result
      |> Map.put(:location_data, decoded)

    decode_continue(rest, result)
  end

  # MT message slice

  defp decode_slice(<<0x41, length::16, header::size(length)-bytes, rest::binary>>, result) do
    debug("header")

    decoded = decode_mt_header(header)

    result =
      result
      |> Map.put(:header, decoded)

    decode_continue(rest, result)
  end

  defp decode_slice(<<0x42, length::16, payload::size(length)-bytes, rest::binary>>, result) do
    debug("payload")

    result =
      result
      |> Map.put(:payload, payload)

    decode_continue(rest, result)
  end

  defp decode_slice(
         <<0x44, _length::16, client_message_id::integer-signed-size(32), imei::size(15)-bytes,
           auto_id::size(32), message_status::integer-signed-size(16), rest::binary>>,
         result
       ) do
    debug("confirmation")

    decoded = %Confirmation{
      client_message_id: client_message_id,
      imei: imei,
      auto_id: auto_id,
      message_status: message_status
    }

    result = result |> Map.put(:confirmation, decoded)

    decode_continue(rest, result)
  end

  # MO header

  defp decode_mt_header(<<cmi::32, imei::size(15)-bytes, disposition_flags::16>>) do
    %MT_Header{
      client_message_id: cmi,
      imei: imei,
      disposition_flags: disposition_flags
    }
  end

  # MT Header
  defp decode_mo_header(
         <<cdr::32, imei::size(15)-bytes, session_status::8, momsn::16, mtmsn::16,
           time_of_session::32>>
       ) do
    time = DateTime.from_unix!(time_of_session)

    %MO_Header{
      cdr: cdr,
      imei: imei,
      session_status: session_status,
      momsn: momsn,
      mtmsn: mtmsn,
      time_of_session: time
    }
  end

  # MO location data
  defp decode_location_data(
         <<_reserved::4, _format_code::2, _nsi::1, _ewi::1, lat::8, latt::16, lon::8, lont::16,
           cep::32>>
       ) do
    %LocationData{lattitude: {lat, latt}, longitude: {lon, lont}, cep: cep}
  end

  defp decode_continue(rest, result) do
    case rest do
      <<>> -> result
      <<rest::binary>> -> decode_slice(rest, result)
      _ -> {:error, "bitstring is not a binary"}
    end
  end
end
