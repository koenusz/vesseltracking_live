defmodule VesseltrackingLive.Certificate do
  @moduledoc """
  The Certificate context.
  """

  import Ecto.Query, warn: false
  alias ElixirSense.Core.Struct
  alias VesseltrackingLive.Repo

  alias VesseltrackingLive.Certificate.TokenUser

  @doc """
  Returns the list of token_users.

  ## Examples

      iex> list_token_users()
      [%TokenUser{}, ...]

  """
  def list_token_users do
    Repo.all(TokenUser)
  end

  @doc """
  Gets a single token_user.

  Raises `Ecto.NoResultsError` if the Token user does not exist.

  ## Examples

      iex> get_token_user!(123)
      %TokenUser{}

      iex> get_token_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_token_user!(id), do: Repo.get!(TokenUser, id)

  def get_token_user_by_pubkey!(pubkey) do
    query =
      from tu in TokenUser,
        where: tu.pubkey == ^pubkey

    Repo.one!(query)
  end

  @doc """
  Creates a token_user.

  ## Examples

      iex> create_token_user(%{field: value})
      {:ok, %TokenUser{}}

      iex> create_token_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_token_user(attrs \\ %{}) do
    %TokenUser{}
    |> TokenUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a token_user.

  ## Examples

      iex> update_token_user(token_user, %{field: new_value})
      {:ok, %TokenUser{}}

      iex> update_token_user(token_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_token_user(%TokenUser{} = token_user, attrs) do
    token_user
    |> TokenUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a token_user.

  ## Examples

      iex> delete_token_user(token_user)
      {:ok, %TokenUser{}}

      iex> delete_token_user(token_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_token_user(%TokenUser{} = token_user) do
    Repo.delete(token_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking token_user changes.

  ## Examples

      iex> change_token_user(token_user)
      %Ecto.Changeset{data: %TokenUser{}}

  """
  def change_token_user(%TokenUser{} = token_user, attrs \\ %{}) do
    TokenUser.changeset(token_user, attrs)
  end
end
