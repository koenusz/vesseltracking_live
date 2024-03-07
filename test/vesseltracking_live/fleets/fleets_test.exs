defmodule Vesseltracking.FleetsTest do
  use Vesseltracking.DataCase

  alias Vesseltracking.Fleets

  import Support.Fixtures

  describe "fleets" do
    alias Vesseltracking.Fleets.Fleet

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "list_fleets/0 returns all fleets" do
      fleet = fleet_fixture()

      [returned] = Fleets.list_fleets()
      assert returned.id == fleet.id
      assert returned.name == fleet.name
    end

    test "get_fleets_by_user/1 returns all for this user" do
      admin = user_fixture(%{email: "super@notadmin.nl", administrator: true})
      no_admin = user_fixture(%{email: "super@admin.nl", administrator: false})
      my_fleet = fleet_fixture(%{name: "my fleet"})
      not_my_fleet = fleet_fixture(%{name: "not my fleet"})
      authorization_fixture(%{user_id: no_admin.id, fleet_id: my_fleet.id})

      assert Fleets.get_fleets_by_user!(admin.id) -- [my_fleet, not_my_fleet] == []

      assert List.first(Fleets.get_fleets_by_user!(no_admin.id)).id == List.first([my_fleet]).id
    end

    test "get_fleets_by_company/1 returns all for this company" do
      company = company_fixture()
      user = user_fixture(%{email: "burp@b131la.nl", administrator: false})
      user2 = user_fixture(%{email: "burp2@bl223a.nl", administrator: false})
      my_fleet = fleet_fixture(%{name: "my fleet", company_id: company.id})
      my_fleet2 = fleet_fixture(%{name: "my fleet2", company_id: company.id})
      authorization_fixture(%{user_id: user.id, fleet_id: my_fleet.id})
      authorization_fixture(%{user_id: user2.id, fleet_id: my_fleet2.id})

      returned = Fleets.get_fleets_by_company(company.id)

      assert length(returned) == 2

      returnedusers =
        returned
        |> Enum.flat_map(fn fleet -> fleet.authorized_users end)
        |> Enum.map(fn x -> x.id end)

      assert user.id in returnedusers
    end

    test "get_fleet!/1 returns the fleet with given id" do
      fleet = fleet_fixture()
      assert Fleets.get_fleet!(fleet.id).id == fleet.id
    end

    test "create_fleet/1 with valid data creates a fleet" do
      company = company_fixture()

      input =
        @valid_attrs
        |> Map.put(:company_id, company.id)

      assert {:ok, %Fleet{} = fleet} = Fleets.create_fleet(input)
      assert fleet.name == "some name"
      returned = Fleets.get_fleet!(fleet.id)

      assert returned.id == fleet.id
      assert length(returned.vessels) == 0
    end

    test "create_fleet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fleets.create_fleet(@invalid_attrs)
    end

    test "update_fleet/2 with invalid data returns error changeset" do
      fleet = fleet_fixture()
      assert {:error, %Ecto.Changeset{}} = Fleets.update_fleet(fleet, @invalid_attrs)
      assert fleet.id == Fleets.get_fleet!(fleet.id).id
    end

    test "delete_fleet/1 deletes the fleet" do
      fleet = fleet_fixture()
      assert {:ok, %Fleet{}} = Fleets.delete_fleet(fleet)
      assert_raise Ecto.NoResultsError, fn -> Fleets.get_fleet!(fleet.id) end
    end

    test "change_fleet/1 returns a fleet changeset" do
      fleet = fleet_fixture()
      assert %Ecto.Changeset{} = Fleets.change_fleet(fleet)
    end
  end

  describe "vessels" do
    alias Vesseltracking.Fleets.Vessel

    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil, tracking_id: nil}

    test "list_vessels/0 returns all vessels" do
      vessel = vessel_fixture()
      assert Fleets.list_vessels() == [vessel]
    end

    test "get_vessel!/1 returns the vessel with given id" do
      vessel = vessel_fixture()
      assert Fleets.get_vessel!(vessel.id) == vessel
    end

    test "get_vessels_by_fleet/1 returns all for this fleet" do
      fleet = fleet_fixture()

      my_vessel = vessel_fixture(%{name: "my vessel", fleet_id: fleet.id})
      my_vessel2 = vessel_fixture(%{name: "my vessel2", fleet_id: fleet.id})

      returned = Fleets.get_vessels_by_fleet_id(fleet.id)

      assert length(returned) == 2
    end

    test "create_vessel/1 with valid data creates a vessel" do
      fleet = fleet_fixture()

      assert {:ok, %Vessel{} = vessel} =
               Fleets.create_vessel(%{
                 name: "some name",
                 fleet_id: fleet.id,
                 tracking_id: "some id"
               })

      assert vessel.name == "some name"

      vessel.tracking_id == "some id"
    end

    test "create_vessel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fleets.create_vessel(@invalid_attrs)
    end

    test "update_vessel/2 with valid data updates the vessel" do
      vessel = vessel_fixture()
      assert {:ok, vessel} = Fleets.update_vessel(vessel, @update_attrs)
      assert %Vessel{} = vessel
      assert vessel.name == "some updated name"
    end

    test "update_vessel/2 with invalid data returns error changeset" do
      vessel = vessel_fixture()
      assert {:error, %Ecto.Changeset{}} = Fleets.update_vessel(vessel, @invalid_attrs)
      assert vessel == Fleets.get_vessel!(vessel.id)
    end

    test "delete_vessel/1 deletes the vessel" do
      vessel = vessel_fixture()
      assert {:ok, %Vessel{}} = Fleets.delete_vessel(vessel)
      assert_raise Ecto.NoResultsError, fn -> Fleets.get_vessel!(vessel.id) end
    end

    test "change_vessel/1 returns a vessel changeset" do
      vessel = vessel_fixture()
      assert %Ecto.Changeset{} = Fleets.change_vessel(vessel)
    end
  end

  describe "authorizations" do
    alias Vesseltracking.Fleets.Authorization

    @update_attrs %{type: "some updated type"}
    @invalid_attrs %{type: 1}

    test "list_authorizations/0 returns all authorizations" do
      authorization = authorization_fixture()
      assert Fleets.list_authorizations() == [authorization]
    end

    test "list_authorizations_by_user_ids/0 returns all authorizations" do
      user = user_fixture()
      fleet = fleet_fixture()
      fleet2 = fleet_fixture()

      attrs = %{user_id: user.id, fleet_id: fleet.id, type: "some type"}
      attrs2 = %{user_id: user.id, fleet_id: fleet2.id, type: "some type2"}

      assert {:ok, %Authorization{} = authorization} = Fleets.create_authorization(attrs)
      assert {:ok, %Authorization{} = authorization2} = Fleets.create_authorization(attrs2)

      stored_ids =
        Fleets.list_authorizations_in_userIds([user.id])
        |> Enum.map(fn aut -> aut.id end)

      ids =
        [authorization, authorization2]
        |> Enum.map(fn aut -> aut.id end)

      assert(ids == stored_ids)
    end

    test "get_authorization!/1 returns the authorization with given id" do
      authorization = authorization_fixture()
      assert Fleets.get_authorization!(authorization.id) == authorization
    end

    test "create_authorization/1 with valid data creates a authorization" do
      user = user_fixture()
      fleet = fleet_fixture()

      attrs = %{user_id: user.id, fleet_id: fleet.id, type: "some type"}

      assert {:ok, %Authorization{} = authorization} = Fleets.create_authorization(attrs)
      assert authorization.type == "some type"
    end

    test "create_authorization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fleets.create_authorization(@invalid_attrs)
    end

    test "update_authorization/2 with valid data updates the authorization" do
      authorization = authorization_fixture()
      assert {:ok, authorization} = Fleets.update_authorization(authorization, @update_attrs)
      assert %Authorization{} = authorization
      assert authorization.type == "some updated type"
    end

    test "update_authorization/2 with invalid data returns error changeset" do
      authorization = authorization_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Fleets.update_authorization(authorization, @invalid_attrs)

      assert authorization == Fleets.get_authorization!(authorization.id)
    end

    test "delete_authorization/1 deletes the authorization" do
      authorization = authorization_fixture()
      assert {:ok, %Authorization{}} = Fleets.delete_authorization(authorization)
      assert_raise Ecto.NoResultsError, fn -> Fleets.get_authorization!(authorization.id) end
    end

    test "change_authorization/1 returns a authorization changeset" do
      authorization = authorization_fixture()
      assert %Ecto.Changeset{} = Fleets.change_authorization(authorization)
    end
  end
end
