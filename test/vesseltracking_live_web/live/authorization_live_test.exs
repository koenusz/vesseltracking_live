defmodule VesseltrackingLiveWeb.AuthorizationLiveTest do
  use VesseltrackingLiveWeb.ConnCase

  import Phoenix.LiveViewTest
  import VesseltrackingLive.FleetsFixtures

  @create_attrs %{users: "some users"}
  @update_attrs %{users: "some updated users"}
  @invalid_attrs %{users: nil}

  defp create_authorization(_) do
    authorization = authorization_fixture()
    %{authorization: authorization}
  end

  describe "Index" do
    setup [:create_authorization]

    test "lists all authorizations", %{conn: conn, authorization: authorization} do
      {:ok, _index_live, html} = live(conn, ~p"/authorizations")

      assert html =~ "Listing Authorizations"
      assert html =~ authorization.users
    end

    test "saves new authorization", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/authorizations")

      assert index_live |> element("a", "New Authorization") |> render_click() =~
               "New Authorization"

      assert_patch(index_live, ~p"/authorizations/new")

      assert index_live
             |> form("#authorization-form", authorization: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#authorization-form", authorization: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/authorizations")

      html = render(index_live)
      assert html =~ "Authorization created successfully"
      assert html =~ "some users"
    end

    test "updates authorization in listing", %{conn: conn, authorization: authorization} do
      {:ok, index_live, _html} = live(conn, ~p"/authorizations")

      assert index_live |> element("#authorizations-#{authorization.id} a", "Edit") |> render_click() =~
               "Edit Authorization"

      assert_patch(index_live, ~p"/authorizations/#{authorization}/edit")

      assert index_live
             |> form("#authorization-form", authorization: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#authorization-form", authorization: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/authorizations")

      html = render(index_live)
      assert html =~ "Authorization updated successfully"
      assert html =~ "some updated users"
    end

    test "deletes authorization in listing", %{conn: conn, authorization: authorization} do
      {:ok, index_live, _html} = live(conn, ~p"/authorizations")

      assert index_live |> element("#authorizations-#{authorization.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#authorizations-#{authorization.id}")
    end
  end

  describe "Show" do
    setup [:create_authorization]

    test "displays authorization", %{conn: conn, authorization: authorization} do
      {:ok, _show_live, html} = live(conn, ~p"/authorizations/#{authorization}")

      assert html =~ "Show Authorization"
      assert html =~ authorization.users
    end

    test "updates authorization within modal", %{conn: conn, authorization: authorization} do
      {:ok, show_live, _html} = live(conn, ~p"/authorizations/#{authorization}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Authorization"

      assert_patch(show_live, ~p"/authorizations/#{authorization}/show/edit")

      assert show_live
             |> form("#authorization-form", authorization: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#authorization-form", authorization: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/authorizations/#{authorization}")

      html = render(show_live)
      assert html =~ "Authorization updated successfully"
      assert html =~ "some updated users"
    end
  end
end
