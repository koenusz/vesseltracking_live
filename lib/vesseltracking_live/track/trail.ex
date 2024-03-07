defmodule Vesseltracking.Track.Trail do
  use Ecto.Schema
  import Ecto.Changeset
  import Logger

  alias Vesseltracking.Track.Trail

  schema "trails" do
    field(:day, :date, default: Date.utc_today())
    field(:steps, {:array, :map}, default: [])
    field(:tracking_id, :string)

    timestamps()
  end

  @doc false
  def changeset(%Trail{} = trail, attrs) do
    trail
    |> cast(attrs, [:day, :tracking_id, :steps])
    |> validate_required([:day, :tracking_id, :steps])
  end

  def post_process_trail(trail) do
    case trail do
      nil ->
        nil

      _ ->
        steps =
          trail.steps
          |> Enum.map(fn step -> %{step | "point" => Geo.JSON.decode!(step["point"])} end)
          |> Enum.map(fn step ->
            %{step | "origin_timestamp" => from_iso8601!(step["origin_timestamp"])}
          end)

        %{trail | steps: steps}
    end
  end

  defp from_iso8601!(time) do
    case DateTime.from_iso8601(time) do
      {:ok, time, _} -> time
      {:error, reason} -> error(reason)
    end
  end
end
