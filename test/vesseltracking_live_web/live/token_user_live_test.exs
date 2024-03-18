defmodule VesseltrackingLiveWeb.TokenUserLiveTest do
  use VesseltrackingLiveWeb.ConnCase

  import Phoenix.LiveViewTest
  import VesseltrackingLive.{CertificateFixtures, AccountsFixtures}

  @update_attrs %{
    comment: "some updated comment",
    approved?: false
  }
  @invalid_attrs %{
    comment: nil,
    approved?: false
  }

  setup_all %{conn: conn} do
    conn =
      conn
      |> log_in_user(user_fixture())

    %{conn: conn}
  end

  defp create_token_user(_) do
    token_user = token_user_fixture()
    %{token_user: token_user}
  end

  describe "Index" do
    setup [:create_token_user]

    test "lists all token_users", %{conn: conn, token_user: token_user} do
      {:ok, _index_live, html} = live(conn, ~p"/token_users")

      assert html =~ "Listing Token users"
      assert html =~ token_user.comment
    end

    test "updates token_user in listing", %{conn: conn, token_user: token_user} do
      {:ok, index_live, _html} = live(conn, ~p"/token_users")

      assert index_live |> element("#token_users-#{token_user.id} a", "Edit") |> render_click() =~
               "Edit Token user"

      assert_patch(index_live, ~p"/token_users/#{token_user}/edit")

      assert index_live
             |> form("#token_user-form", token_user: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#token_user-form", token_user: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/token_users")

      html = render(index_live)
      assert html =~ "Token user updated successfully"
      assert html =~ "some updated comment"
    end

    test "deletes token_user in listing", %{conn: conn, token_user: token_user} do
      {:ok, index_live, _html} = live(conn, ~p"/token_users")

      assert index_live |> element("#token_users-#{token_user.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#token_users-#{token_user.id}")
    end
  end

  describe "Show" do
    setup [:create_token_user]

    test "displays token_user", %{conn: conn, token_user: token_user} do
      {:ok, _show_live, html} = live(conn, ~p"/token_users/#{token_user}")

      assert html =~ "Show Token user"
      assert html =~ token_user.comment
    end

    test "updates token_user within modal", %{conn: conn, token_user: token_user} do
      {:ok, show_live, _html} = live(conn, ~p"/token_users/#{token_user}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Token user"

      assert_patch(show_live, ~p"/token_users/#{token_user}/show/edit")

      assert show_live
             |> form("#token_user-form", token_user: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#token_user-form", token_user: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/token_users/#{token_user}")

      html = render(show_live)
      assert html =~ "Token user updated successfully"
      assert html =~ "some updated comment"
    end
  end
end
