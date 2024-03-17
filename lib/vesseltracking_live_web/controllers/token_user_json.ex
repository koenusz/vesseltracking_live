defmodule VesseltrackingLiveWeb.TokenUserJSON do
  alias VesseltrackingLive.Certificate.TokenUser

  @doc """
  Renders a list of token_users.
  """
  def index(%{token_users: token_users}) do
    %{data: for(token_user <- token_users, do: data(token_user))}
  end

  @doc """
  Renders a single token_user.
  """
  def show(%{token_user: token_user}) do
    %{data: data(token_user)}
  end

  defp data(%TokenUser{} = token_user) do
    %{
      id: token_user.id,
      username: token_user.username,
      pubkey: token_user.pubkey,
      approved?: token_user.approved?,
      created_at: token_user.created_at,
      expires_at: token_user.expires_at,
      comment: token_user.comment
    }
  end
end
