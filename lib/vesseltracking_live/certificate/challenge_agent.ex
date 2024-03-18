defmodule VesseltrackingLive.Certificate.ChallengeAgent do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value.random end, name: initial_value.token_user_id)
  end

  def challenge(token_user_id, decrypted) do
    Agent.get(token_user_id, & &1) == decrypted
  end
end
