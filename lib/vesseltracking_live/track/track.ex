defmodule VesseltrackingLive.Track do
  @moduledoc """
  The Track context.
  """

  import Ecto.Query, warn: false
  alias VesseltrackingLive.Repo

  alias VesseltrackingLive.Fleets.Vessel
  alias VesseltrackingLive.PointAdapter
  alias VesseltrackingLive.Track.{Step, Trail, Trackworker}

  @doc """
  Translate inpot sent to the application to a %Geo.Point{} .

  ## Examples

      iex> translate(%Geo.Point{coordinates{30.0, 2.0}})
      {:ok, %Geo.Point{}}

      iex> translate(%{field: bad_value})
      {:error, input}

  """
  def translate(point) do
    PointAdapter.translate(point)
  end

  @doc """
  Returns the list of trails.

  ## Examples

      iex> list_trails()
      [%Trail{}, ...]

  """
  def list_trails do
    Repo.all(Trail) |> Enum.map(&Trail.post_process_trail(&1))
  end

  @doc """
  Returns the list of unclaimed trails.

  ## Examples

      iex> list_unclaimed_trails()
      [%Trail{}, ...]

  """
  def list_unclaimed_trails do
    query =
      from(t in Trail,
        left_join: v in Vessel,
        on: t.tracking_id == v.tracking_id,
        select: t,
        distinct: :tracking_id,
        where: is_nil(v.id)
      )

    Repo.all(query)
    |> Enum.map(&Trail.post_process_trail(&1))
  end

  @doc """
  Gets a single trail.

  Raises `Ecto.NoResultsError` if the Trail does not exist.

  ## Examples

      iex> get_trail!(123)
      %Trail{}

      iex> get_trail!(456)
      ** (Ecto.NoResultsError)

  """
  def get_trail!(id), do: Repo.get!(Trail, id) |> Trail.post_process_trail()

  def get_trail_from_worker(tracking_id) do
    Trackworker.get_trail(tracking_id)
  end

  @doc """
  Gets a today's trail.

  ## Examples

      iex> get_todays_trail(123)
      %Trail{}

      iex> get_todays_trail(456)
      nil

  """
  def get_todays_trail(tracking_id) do
    today = Date.utc_today()

    query =
      from(
        t in Trail,
        where: t.day == ^today and t.tracking_id == ^tracking_id
      )

    Repo.one(query)
    |> Trail.post_process_trail()
  end

  @doc """
  Gets a list of trails from the last amount of days.

  ## Examples

      iex> get_last_trails_by_tracking_id(123, 1)
      [%Trail{}]

      iex> get_last_trails_by_tracking_id(456, 1)
      []

  """
  def get_last_trails_by_tracking_id(tracking_id, amount) do
    query =
      from(
        t in Trail,
        where: t.tracking_id == ^tracking_id,
        order_by: [desc: :day],
        limit: ^amount
      )

    Repo.all(query)
    |> Enum.map(&Trail.post_process_trail(&1))
  end

  @doc """
  Creates a trail.

  ## Examples

      iex> create_trail(%{field: value})
      {:ok, %Trail{}}

      iex> create_trail(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_trail(attrs \\ %{}) do
    %Trail{}
    |> Trail.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a trail.

  ## Examples

      iex> update_trail(trail, %{field: new_value})
      {:ok, %Trail{}}

      iex> update_trail(trail, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_trail(%Trail{} = trail, attrs) do
    trail
    |> Trail.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Trail.

  ## Examples

      iex> delete_trail(trail)
      {:ok, %Trail{}}

      iex> delete_trail(trail)
      {:error, %Ecto.Changeset{}}

  """
  def delete_trail(%Trail{} = trail) do
    Repo.delete(trail)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking trail changes.

  ## Examples

      iex> change_trail(trail)
      %Ecto.Changeset{source: %Trail{}}

  """
  def change_trail(%Trail{} = trail, attrs \\ %{}) do
    Trail.changeset(trail, attrs)
  end

  @doc """
  Returns a `%VesseltrackingLive.Track.Trail{}` .

  ## Examples

      iex> add_step(tracking_id, step)
      %Trail{}

  """
  def add_step(tracking_id, %Step{} = step) do
    Trackworker.add_step(tracking_id, step)
  end
end
