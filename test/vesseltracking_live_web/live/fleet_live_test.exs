defmodule VesseltrackingLiveWeb.FleetLiveTest do
  use VesseltrackingLiveWeb.ConnCase

  import Phoenix.LiveViewTest
  import Support.Fixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_fleet(_) do
    fleet = fleet_fixture()
    %{fleet: fleet}
  end

  describe "Index" do
    setup [:create_fleet]

    test "lists all fleets", %{conn: conn, fleet: fleet} do
      {:ok, _index_live, html} = live(conn, ~p"/fleets")

      assert html =~ "Listing Fleets"
      assert html =~ fleet.name
    end

    test "saves new fleet", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/fleets")

      assert index_live |> element("a", "New Fleet") |> render_click() =~
               "New Fleet"

      assert_patch(index_live, ~p"/fleets/new")

      assert index_live
             |> form("#fleet-form", fleet: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#fleet-form", fleet: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/fleets")

      html = render(index_live)
      assert html =~ "Fleet created successfully"
      assert html =~ "some name"
    end

    test "updates fleet in listing", %{conn: conn, fleet: fleet} do
      {:ok, index_live, _html} = live(conn, ~p"/fleets")

      assert index_live |> element("#fleets-#{fleet.id} a", "Edit") |> render_click() =~
               "Edit Fleet"

      assert_patch(index_live, ~p"/fleets/#{fleet}/edit")

      assert index_live
             |> form("#fleet-form", fleet: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#fleet-form", fleet: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/fleets")

      html = render(index_live)
      assert html =~ "Fleet updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes fleet in listing", %{conn: conn, fleet: fleet} do
      {:ok, index_live, _html} = live(conn, ~p"/fleets")

      assert index_live |> element("#fleets-#{fleet.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#fleets-#{fleet.id}")
    end
  end

  describe "Show" do
    setup [:create_fleet]

    test "displays fleet", %{conn: conn, fleet: fleet} do
      {:ok, _show_live, html} = live(conn, ~p"/fleets/#{fleet}")

      assert html =~ "Show Fleet"
      assert html =~ fleet.name
    end

    test "updates fleet within modal", %{conn: conn, fleet: fleet} do
      {:ok, show_live, _html} = live(conn, ~p"/fleets/#{fleet}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Fleet"

      assert_patch(show_live, ~p"/fleets/#{fleet}/show/edit")

      assert show_live
             |> form("#fleet-form", fleet: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#fleet-form", fleet: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/fleets/#{fleet}")

      html = render(show_live)
      assert html =~ "Fleet updated successfully"
      assert html =~ "some updated name"
    end
  end
end
