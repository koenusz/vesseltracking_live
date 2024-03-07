defmodule Vesseltracking.Track.Trackworker do
  use GenServer

  alias Vesseltracking.Track
  alias Vesseltracking.Track.{Trail, Step}

  @doc """
  Starts a tracking worker.
  """
  def start_link(tracking_id, opts \\ []) do
    GenServer.start_link(__MODULE__, {:ok, tracking_id}, opts)
  end

  # client interface

  @doc """
  Add a %Vesseltracking.Track.Step{} to the workers trail.

  ## Examples

      iex> add_step(worker, %Vesseltracking.Track.Step{})
      {:ok, %Trail{}}

      iex> add_step(456)
      {:error, message}
  """

  def add_step(worker, step) do
    {:ok, GenServer.call(worker, {:add_step, step})}
  end

  @doc """
  Inspect the trail contained in the worker.
  """
  def get_trail(worker) do
    GenServer.call(worker, {:get})
  end

  @doc """
  Stores the state of the worker to the databse.
  """
  def store_state(worker) do
    GenServer.call(worker, {:store})
  end

  # server callbacks

  @doc """
  Initialises a trail worker with a trail.
  """
  def init({:ok, tracking_id}) do
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

    {:reply, new_trail, new_trail}
  end

  def handle_call({:get}, _from, %Vesseltracking.Track.Trail{} = trail) do
    {:reply, trail, trail}
  end

  def handle_call({:store}, _from, %Vesseltracking.Track.Trail{} = state) do
    {:ok, trail} =
      Track.get_todays_trail(state.tracking_id)
      |> Track.update_trail(%{"steps" => state.steps})

    {:reply, trail, trail}
  end

  # swarm callbacks

  # called when a handoff has been initiated due to changes
  # in cluster topology, valid response values are:
  #
  #   - `:restart`, to simply restart the process on the new node
  #   - `{:resume, state}`, to hand off some state to the new process
  #   - `:ignore`, to leave the process running on its current node
  #
  def handle_call({:swarm, :begin_handoff}, _from, {name, delay}) do
    {:reply, {:resume, delay}, {name, delay}}
  end

  # called after the process has been restarted on its new node,
  # and the old process' state is being handed off. This is only
  # sent if the return to `begin_handoff` was `{:resume, state}`.
  # **NOTE**: This is called *after* the process is successfully started,
  # so make sure to design your processes around this caveat if you
  # wish to hand off state like this.
  def handle_cast({:swarm, :end_handoff, delay}, {name, _}) do
    {:noreply, {name, delay}}
  end

  # called when a network split is healed and the local process
  # should continue running, but a duplicate process on the other
  # side of the split is handing off its state to us. You can choose
  # to ignore the handoff state, or apply your own conflict resolution
  # strategy
  def handle_cast({:swarm, :resolve_conflict, _delay}, state) do
    {:noreply, state}
  end

  def handle_info(:timeout, {name, delay}) do
    Process.send_after(self(), :timeout, delay)
    {:noreply, {name, delay}}
  end

  # this message is sent when this process should die
  # because it is being moved, use this as an opportunity
  # to clean up
  def handle_info({:swarm, :die}, state) do
    {:stop, :shutdown, state}
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
end
