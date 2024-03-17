defmodule VesseltrackingLive.CertificateTest do
  use VesseltrackingLive.DataCase

  alias VesseltrackingLive.Certificate

  describe "token_users" do
    alias VesseltrackingLive.Certificate.TokenUser

    import VesseltrackingLive.CertificateFixtures

    @invalid_attrs %{
      comment: nil,
      username: nil,
      pubkey: nil,
      approved?: nil,
      created_at: nil,
      expires_at: nil
    }

    test "list_token_users/0 returns all token_users" do
      token_user = token_user_fixture()
      assert Certificate.list_token_users() == [token_user]
    end

    test "get_token_user!/1 returns the token_user with given id" do
      token_user = token_user_fixture()
      assert Certificate.get_token_user!(token_user.id) == token_user
    end

    test "get_token_user_by_pubkey!/1 returns the token_user with given publik key" do
      token_user = token_user_fixture()
      result = Certificate.get_token_user_by_pubkey!(token_user.pubkey)

      assert %TokenUser{} = result
      assert result.pubkey == token_user.pubkey
    end

    test "create_token_user/1 with valid data creates a token_user" do
      valid_attrs = %{
        comment: "some comment",
        username: "some username",
        pubkey: "some pubkey",
        approved?: true,
        created_at: ~U[2024-03-16 10:04:00Z],
        expires_at: ~U[2024-03-16 10:04:00Z]
      }

      assert {:ok, %TokenUser{} = token_user} = Certificate.create_token_user(valid_attrs)
      assert token_user.comment == "some comment"
      assert token_user.username == "some username"
      assert token_user.pubkey == "some pubkey"
      assert token_user.approved? == true
      assert token_user.created_at == ~U[2024-03-16 10:04:00Z]
      assert token_user.expires_at == ~U[2024-03-16 10:04:00Z]
    end

    test "create_token_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Certificate.create_token_user(@invalid_attrs)
    end

    test "update_token_user/2 with valid data updates the token_user" do
      token_user = token_user_fixture()

      update_attrs = %{
        comment: "some updated comment",
        username: "some updated username",
        pubkey: "some updated pubkey",
        approved?: false,
        created_at: ~U[2024-03-17 10:04:00Z],
        expires_at: ~U[2024-03-17 10:04:00Z]
      }

      assert {:ok, %TokenUser{} = token_user} =
               Certificate.update_token_user(token_user, update_attrs)

      assert token_user.comment == "some updated comment"
      assert token_user.username == "some updated username"
      assert token_user.pubkey == "some updated pubkey"
      assert token_user.approved? == false
      assert token_user.created_at == ~U[2024-03-17 10:04:00Z]
      assert token_user.expires_at == ~U[2024-03-17 10:04:00Z]
    end

    test "update_token_user/2 with invalid data returns error changeset" do
      token_user = token_user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Certificate.update_token_user(token_user, @invalid_attrs)

      assert token_user == Certificate.get_token_user!(token_user.id)
    end

    test "delete_token_user/1 deletes the token_user" do
      token_user = token_user_fixture()
      assert {:ok, %TokenUser{}} = Certificate.delete_token_user(token_user)
      assert_raise Ecto.NoResultsError, fn -> Certificate.get_token_user!(token_user.id) end
    end

    test "change_token_user/1 returns a token_user changeset" do
      token_user = token_user_fixture()
      assert %Ecto.Changeset{} = Certificate.change_token_user(token_user)
    end
  end
end
