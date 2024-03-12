defmodule VesseltrackingLive.Track.Trackworker do
  use GenServer, restart: :temporary

  alias VesseltrackingLive.Track
  alias VesseltrackingLive.Track.{Trail, Step}

  @doc """
  Starts a tracking worker.
  """
  def start_link(params) do
    GenServer.start_link(__MODULE__, params[:tracking_id], name: via(params[:tracking_id]))
  end

  # client interface

  @doc """
  Add a %VesseltrackingLive.Track.Step{} to the workers trail.

  ## Examples

      iex> add_step(worker, %VesseltrackingLive.Track.Step{})
      {:ok, %Trail{}}

      iex> add_step(456)
      {:error, message}
  """

  def add_step(tracking_id, step) do
    case Registry.lookup(VesseltrackingLive.Track.TrackRegistry, tracking_id) do
      [] -> VesseltrackingLive.Track.Supervisor.start_child(tracking_id)
      val -> val
    end

    {:ok, GenServer.call(via(tracking_id), {:add_step, step})}
  end

  def get_trail(tracking_id) do
    GenServer.call(via(tracking_id), :get)
  end

  def store_state(tracking_id) do
    GenServer.cast(via(tracking_id), :store)
  end

  # server callbacks

  def init(tracking_id) do
    {:ok, init_state(tracking_id)}
  end

  def handle_call({:add_step, %Step{} = step}, from, %Trail{} = trail) do
    handle_call({:add_step, Step.to_map(step)}, from, trail)
  end

  def handle_call({:add_step, %{} = step}, _from, %Trail{} = trail) do
    trail =
      if trail.day == Date.utc_today() do
        trail
      else
        init_state(trail.tracking_id)
      end

    new_trail =
      trail.steps
      |> (fn steps -> [step | steps] end).()
      |> (fn steps -> %{trail | steps: steps} end).()

    store(trail)

    {:reply, new_trail, new_trail}
  end

  def handle_call(:get, _from, %VesseltrackingLive.Track.Trail{} = trail) do
    {:reply, trail, trail}
  end

  def handle_cast(:store, %VesseltrackingLive.Track.Trail{} = state) do
    {:ok, trail} = store(state)

    {:noreply, trail}
  end

  defp store(state) do
    Track.get_todays_trail(state.tracking_id)
    |> Track.update_trail(%{"steps" => state.steps})
  end

  defp init_state(tracking_id) do
    case Track.get_todays_trail(tracking_id) do
      %Trail{} = trail ->
        trail

      nil ->
        {:ok, _} = Track.create_trail(%{day: Date.utc_today(), tracking_id: tracking_id})

        Track.get_todays_trail(tracking_id)
    end
  end

  defp via(tracking_id),
    do: {:via, Registry, {VesseltrackingLive.Track.TrackRegistry, tracking_id}}
end
