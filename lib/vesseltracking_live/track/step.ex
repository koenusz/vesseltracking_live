defmodule VesseltrackingLive.Track.Step do
  use Ecto.Schema
  import Ecto.Changeset

  alias VesseltrackingLive.Track.Step

  # embedded_schema is short for:
  #
  #   @primary_key {:id, :binary_id, autogenerate: true}
  #   schema "embedded Item" do
  #
  @derive Jason.Encoder
  embedded_schema do
    field(:origin_timestamp, :utc_datetime)
    field(:call_data_record, :integer)
    field(:session_status, :integer)
    field(:mobile_originated_message_number, :integer)
    field(:mobile_terminated_message_number, :integer)
    field(:point, Geo.PostGIS.Geometry)
    field(:speed, :integer)
    field(:heading, :integer)
    field(:altitude, :integer)
    # perhaps delete this if it does not cause backwards compatibility issues
    field(:status, :string)
    # idem
    field(:event, :string)
    field(:emergency, :string)
    field(:sensor1, :string)
    field(:sensor2, :string)
    field(:analogue_mask, :integer)
    field(:analogue_data, {:array, :float})
    field(:text_message, :string)
    timestamps()
  end

  @doc false
  def changeset(%{} = step, attrs) do
    step
    |> cast(attrs, [:origin_timestamp, :point])
    |> validate_required([:origin_timestamp, :point])
  end

  def from_point(%Geo.Point{} = point) do
    %__MODULE__{origin_timestamp: DateTime.utc_now(), point: point}
  end

  def to_map(%Step{} = step) do
    step
    |> Map.from_struct()
    |> Enum.reject(fn {_, val} -> val == nil end)
    |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
  end
end
