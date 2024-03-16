defmodule VesseltrackingLive.Fleets do
  @moduledoc """
  The Fleets context.
  """

  import Ecto.Query, warn: false
  alias VesseltrackingLive.Repo

  alias VesseltrackingLive.Fleets.Fleet
  alias VesseltrackingLive.Fleets.Vessel
  alias VesseltrackingLive.Fleets.Authorization

  @doc """
  Returns the list of fleets.

  ## Examples

      iex> list_fleets()
      [%Fleet{}, ...]

  """
  def list_fleets do
    Repo.all(from(f in Fleet, preload: [:vessels]))
  end

  @doc """
  Returns the list of fleets for this user.

  ## Examples

      iex> get_fleets_by_user!(1)
      [%Fleet{}, ...]

      iex> get_fleets_by_user!(456)
      ** (Ecto.NoResultsError)
  """
  def get_fleets_by_user!(user_id) do
    query =
      from(
        f in Fleet,
        join: aut in Authorization,
        on: f.id == aut.fleet_id and aut.user_id == ^user_id,
        preload: [:vessels],
        preload: [:authorized_users]
      )

    Repo.all(query)
  end

  @doc """
  Gets a single fleet.

  Raises `Ecto.NoResultsError` if the Fleet does not exist.

  ## Examples

      iex> get_fleet!(123)
      %Fleet{}

      iex> get_fleet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_fleet!(id),
    do:
      Repo.get!(Fleet, id)
      |> Repo.preload(:vessels)

  @doc """
  Creates a fleet.

  ## Examples

      iex> create_fleet(%{field: value})
      {:ok, %Fleet{}}

      iex> create_fleet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_fleet(attrs \\ %{}) do
    %Fleet{}
    |> Fleet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a fleet.

  ## Examples

      iex> update_fleet(fleet, %{field: new_value})
      {:ok, %Fleet{}}

      iex> update_fleet(fleet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_fleet(%Fleet{} = fleet, attrs) do
    fleet
    |> Fleet.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Fleet.

  ## Examples

      iex> delete_fleet(fleet)
      {:ok, %Fleet{}}

      iex> delete_fleet(fleet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_fleet(%Fleet{} = fleet) do
    Repo.delete(fleet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking fleet changes.

  ## Examples

      iex> change_fleet(fleet)
      %Ecto.Changeset{source: %Fleet{}}

  """
  def change_fleet(%Fleet{} = fleet, attrs \\ %{}) do
    Fleet.changeset(fleet, attrs)
  end

  @doc """
  Returns the list of vessels.

  ## Examples

      iex> list_vessels()
      [%Vessel{}, ...]

  """
  def list_vessels do
    Repo.all(Vessel)
  end

  @doc """
  Gets a single vessel.

  Raises `Ecto.NoResultsError` if the Vessel does not exist.

  ## Examples

      iex> get_vessel!(123)
      %Vessel{}

      iex> get_vessel!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vessel!(id), do: Repo.get!(Vessel, id)

  @doc """
  Returns the list of vessels for this fleet.

  ## Examples

      iex> get_vessels_by_fleet!(1)
      [%Vessel{}, ...]
  """
  def get_vessels_by_fleet_id(fleet_id) do
    query =
      from(
        v in Vessel,
        where: v.fleet_id == ^fleet_id
      )

    Repo.all(query)
  end

  @doc """
  Returns the vessel for this tracking id.

  ## Examples

  iex> get_vessels_by_tracking_id!(1)
  %Vessel{}
  """
  def get_vessels_by_tracking_id(tracking_id) do
    query =
      from(
        v in Vessel,
        where: v.tracking_id == ^tracking_id
      )

    Repo.one(query)
  end

  @doc """
  Creates a vessel.

  ## Examples

      iex> create_vessel(%{field: value})
      {:ok, %Vessel{}}

      iex> create_vessel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vessel(attrs \\ %{}) do
    %Vessel{}
    |> Vessel.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vessel.

  ## Examples

      iex> update_vessel(vessel, %{field: new_value})
      {:ok, %Vessel{}}

      iex> update_vessel(vessel, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vessel(%Vessel{} = vessel, attrs) do
    vessel
    |> Vessel.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Vessel.

  ## Examples

      iex> delete_vessel(vessel)
      {:ok, %Vessel{}}

      iex> delete_vessel(vessel)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vessel(%Vessel{} = vessel) do
    Repo.delete(vessel)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vessel changes.

  ## Examples

      iex> change_vessel(vessel)
      %Ecto.Changeset{source: %Vessel{}}

  """
  def change_vessel(%Vessel{} = vessel, attrs \\ %{}) do
    Vessel.changeset(vessel, attrs)
  end

  @doc """
  Returns the list of authorizations.

  ## Examples

      iex> list_authorizations()
      [%Authorization{}, ...]

  """
  def list_authorizations do
    Repo.all(Authorization)
  end

  @doc """
  Returns the list of authorizations that belong to the users in the list.

  ## Examples

      iex> list_authorizations(user_ids)
      [%Authorization{}, ...]

  """
  def list_authorizations_in_userIds(user_ids) do
    from(a in Authorization, where: a.user_id in ^user_ids, preload: [:fleet])
    |> Repo.all()
  end

  @doc """
  Returns the list of authorizations that belong to the users in the list.

  ## Examples

      iex> list_authorizations(user_ids)
      [%Authorization{}, ...]

  """
  def list_authorizations_by_fleet_id(fleet_id) do
    from(a in Authorization, where: a.fleet_id == ^fleet_id, preload: [:user])
    |> Repo.all()
  end

  @doc """
  Gets a single authorization.

  Raises `Ecto.NoResultsError` if the Authorization does not exist.

  ## Examples

      iex> get_authorization!(123)
      %Authorization{}

      iex> get_authorization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_authorization!(id), do: Repo.get!(Authorization, id)

  @doc """
  Gets a single authorization.


  ## Examples

      iex> get_authorization(1, 1)
     %Authorization{}

      iex> get_authorization(%{})
     nil

  """
  def get_authorization_by_fleet_and_employee(user_id, fleet_id) do
    from(a in Authorization, where: a.user_id == ^user_id and a.fleet_id == ^fleet_id)
    |> Repo.one()
  end

  @doc """
  Creates a authorization.

  ## Examples

      iex> create_authorization(%{field: value})
      {:ok, %Authorization{}}

      iex> create_authorization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_authorization(attrs \\ %{}) do
    %Authorization{}
    |> Authorization.changeset(attrs)
    |> Repo.insert()
    |> preload_user()
  end

  defp preload_user({:ok, authorization}), do: {:ok, Repo.preload(authorization, [:user])}
  defp preload_user(error), do: error

  @doc """
  Updates a authorization.

  ## Examples

      iex> update_authorization(authorization, %{field: new_value})
      {:ok, %Authorization{}}

      iex> update_authorization(authorization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_authorization(%Authorization{} = authorization, attrs) do
    authorization
    |> Authorization.changeset(attrs)
    |> Repo.update()
    |> preload_user()
  end

  @doc """
  Deletes a Authorization.

  ## Examples

      iex> delete_authorization(authorization)
      {:ok, %Authorization{}}

      iex> delete_authorization(authorization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_authorization(%Authorization{} = authorization) do
    Repo.delete(authorization)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking authorization changes.

  ## Examples

      iex> change_authorization(authorization)
      %Ecto.Changeset{source: %Authorization{}}

  """
  def change_authorization(%Authorization{} = authorization, attrs \\ %{}) do
    Authorization.changeset(authorization, attrs)
  end
end
