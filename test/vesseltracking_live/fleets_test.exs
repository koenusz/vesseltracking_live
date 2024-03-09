defmodule VesseltrackingLive.FleetsTest do
  alias VesseltrackingLive.AccountsFixtures
  use VesseltrackingLive.DataCase

  alias VesseltrackingLive.Fleets

  import Support.Fixtures
  import VesseltrackingLive.AccountsFixtures

  setup %{} do
    user = AccountsFixtures.user_fixture()
    fleet = fleet_fixture(%{name: "my fleet"})

    %{
      user: user,
      fleet: fleet,
      authorization: authorization_fixture(%{user_id: user.id, fleet_id: fleet.id})
    }
  end

  describe "fleets" do
    alias VesseltrackingLive.Fleets.Fleet

    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "list_fleets/0 returns all fleets", %{fleet: fleet} do
      [returned] = Fleets.list_fleets()
      assert returned.id == fleet.id
      assert returned.name == fleet.name
    end

    test "get_fleets_by_user/1 returns all for this user", %{fleet: fleet, user: user} do
      other_user = AccountsFixtures.user_fixture()
      other_fleet = fleet_fixture(%{name: "other fleet"})
      authorization_fixture(%{user_id: other_user.id, fleet_id: other_fleet.id})

      result = Fleets.get_fleets_by_user!(user.id)
      assert length(result) == 1

      assert fleet.id == hd(result).id
    end

    test "get_fleet!/1 returns the fleet with given id", %{fleet: fleet} do
      assert Fleets.get_fleet!(fleet.id).id == fleet.id
    end

    test "create_fleet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fleets.create_fleet(@invalid_attrs)
    end

    test "update_fleet/2 with invalid data returns error changeset", %{fleet: fleet} do
      assert {:error, %Ecto.Changeset{}} = Fleets.update_fleet(fleet, @invalid_attrs)
      assert fleet.id == Fleets.get_fleet!(fleet.id).id
    end

    test "delete_fleet/1 deletes the fleet", %{fleet: fleet} do
      assert {:ok, %Fleet{}} = Fleets.delete_fleet(fleet)
      assert_raise Ecto.NoResultsError, fn -> Fleets.get_fleet!(fleet.id) end
    end

    test "change_fleet/1 returns a fleet changeset", %{fleet: fleet} do
      assert %Ecto.Changeset{} = Fleets.change_fleet(fleet)
    end
  end

  describe "vessels" do
    alias VesseltrackingLive.Fleets.Vessel

    setup %{fleet: fleet} do
      %{vessel: vessel_fixture(%{fleet: fleet})}
    end

    def vessel_params(fleet_id) do
      %{
        name: "some other name",
        fleet_id: fleet_id,
        tracking_id: "some id"
      }
    end

    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil, tracking_id: nil}

    test "list_vessels/0 returns all vessels", %{vessel: vessel} do
      assert Fleets.list_vessels() == [vessel]
    end

    test "get_vessel!/1 returns the vessel with given id", %{vessel: vessel} do
      assert Fleets.get_vessel!(vessel.id) == vessel
    end

    test "get_vessels_by_fleet/1 returns all for this fleet", %{fleet: fleet} do
      Fleets.create_vessel(vessel_params(fleet.id))

      returned = Fleets.get_vessels_by_fleet_id(fleet.id)
      assert length(returned) == 2
    end

    test "inserting two vessels witht he same tracking id gives an error", %{fleet: fleet} do
      Fleets.create_vessel(vessel_params(fleet.id))
      assert_raise(Ecto.ConstraintError, fn -> Fleets.create_vessel(vessel_params(fleet.id)) end)
    end

    test "create_vessel/1 with valid data creates a vessel", %{fleet: fleet} do
      assert {:ok, %Vessel{} = vessel} =
               Fleets.create_vessel(%{
                 name: "some name",
                 fleet_id: fleet.id,
                 tracking_id: "some id"
               })

      assert vessel.name == "some name"
      assert vessel.tracking_id == "some id"
    end

    test "create_vessel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fleets.create_vessel(@invalid_attrs)
    end

    test "update_vessel/2 with valid data updates the vessel", %{vessel: vessel} do
      assert {:ok, vessel} = Fleets.update_vessel(vessel, @update_attrs)
      assert %Vessel{} = vessel
      assert vessel.name == "some updated name"
    end

    test "update_vessel/2 with invalid data returns error changeset", %{vessel: vessel} do
      assert {:error, %Ecto.Changeset{}} = Fleets.update_vessel(vessel, @invalid_attrs)
      assert vessel == Fleets.get_vessel!(vessel.id)
    end

    test "delete_vessel/1 deletes the vessel", %{vessel: vessel} do
      assert {:ok, %Vessel{}} = Fleets.delete_vessel(vessel)
      assert_raise Ecto.NoResultsError, fn -> Fleets.get_vessel!(vessel.id) end
    end

    test "change_vessel/1 returns a vessel changeset", %{vessel: vessel} do
      assert %Ecto.Changeset{} = Fleets.change_vessel(vessel)
    end
  end

  describe "authorizations" do
    alias VesseltrackingLive.Fleets.Authorization

    @update_attrs %{type: "some updated type"}
    @invalid_attrs %{type: 1}

    test "list_authorizations/0 returns all authorizations", %{authorization: authorization} do
      assert Fleets.list_authorizations() == [authorization]
    end

    test "list_authorizations_by_user_ids/0 returns all authorizations", %{
      user: user,
      authorization: authorization
    } do
      fleet2 = fleet_fixture()

      attrs2 = %{user_id: user.id, fleet_id: fleet2.id, type: "some type2"}

      assert {:ok, %Authorization{} = authorization2} = Fleets.create_authorization(attrs2)

      stored_ids =
        Fleets.list_authorizations_in_userIds([user.id])
        |> Enum.map(fn aut -> aut.id end)

      ids =
        [authorization, authorization2]
        |> Enum.map(fn aut -> aut.id end)

      assert(ids == stored_ids)
    end

    test "get_authorization!/1 returns the authorization with given id", %{
      authorization: authorization
    } do
      assert Fleets.get_authorization!(authorization.id) == authorization
    end

    test "create_authorization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fleets.create_authorization(@invalid_attrs)
    end

    test "update_authorization/2 with valid data updates the authorization", %{
      authorization: authorization
    } do
      assert {:ok, authorization} = Fleets.update_authorization(authorization, @update_attrs)
      assert %Authorization{} = authorization
      assert authorization.type == "some updated type"
    end

    test "update_authorization/2 with invalid data returns error changeset", %{
      authorization: authorization
    } do
      assert {:error, %Ecto.Changeset{}} =
               Fleets.update_authorization(authorization, @invalid_attrs)

      assert authorization == Fleets.get_authorization!(authorization.id)
    end

    test "delete_authorization/1 deletes the authorization", %{
      authorization: authorization
    } do
      assert {:ok, %Authorization{}} = Fleets.delete_authorization(authorization)
      assert_raise Ecto.NoResultsError, fn -> Fleets.get_authorization!(authorization.id) end
    end

    test "change_authorization/1 returns a authorization changeset", %{
      authorization: authorization
    } do
      assert %Ecto.Changeset{} = Fleets.change_authorization(authorization)
    end
  end
end
