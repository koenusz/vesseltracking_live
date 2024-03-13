defmodule VesseltrackingLiveWeb.VesselLiveTest do
  use VesseltrackingLiveWeb.ConnCase

  import Phoenix.LiveViewTest
  import VesseltrackingLive.FleetsFixtures

  @create_attrs %{name: "some name", tracking_id: "some tracking_id"}
  @update_attrs %{name: "some updated name", tracking_id: "some updated tracking_id"}
  @invalid_attrs %{name: nil, tracking_id: nil}

  defp create_vessel(_) do
    vessel = vessel_fixture()
    %{vessel: vessel}
  end

  describe "Index" do
    setup [:create_vessel]

    test "lists all vessels", %{conn: conn, vessel: vessel} do
      {:ok, _index_live, html} = live(conn, ~p"/vessels")

      assert html =~ "Listing Vessels"
      assert html =~ vessel.name
    end

    test "saves new vessel", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/vessels")

      assert index_live |> element("a", "New Vessel") |> render_click() =~
               "New Vessel"

      assert_patch(index_live, ~p"/vessels/new")

      assert index_live
             |> form("#vessel-form", vessel: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#vessel-form", vessel: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/vessels")

      html = render(index_live)
      assert html =~ "Vessel created successfully"
      assert html =~ "some name"
    end

    test "updates vessel in listing", %{conn: conn, vessel: vessel} do
      {:ok, index_live, _html} = live(conn, ~p"/vessels")

      assert index_live |> element("#vessels-#{vessel.id} a", "Edit") |> render_click() =~
               "Edit Vessel"

      assert_patch(index_live, ~p"/vessels/#{vessel}/edit")

      assert index_live
             |> form("#vessel-form", vessel: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#vessel-form", vessel: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/vessels")

      html = render(index_live)
      assert html =~ "Vessel updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes vessel in listing", %{conn: conn, vessel: vessel} do
      {:ok, index_live, _html} = live(conn, ~p"/vessels")

      assert index_live |> element("#vessels-#{vessel.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#vessels-#{vessel.id}")
    end
  end

  describe "Show" do
    setup [:create_vessel]

    test "displays vessel", %{conn: conn, vessel: vessel} do
      {:ok, _show_live, html} = live(conn, ~p"/vessels/#{vessel}")

      assert html =~ "Show Vessel"
      assert html =~ vessel.name
    end

    test "updates vessel within modal", %{conn: conn, vessel: vessel} do
      {:ok, show_live, _html} = live(conn, ~p"/vessels/#{vessel}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Vessel"

      assert_patch(show_live, ~p"/vessels/#{vessel}/show/edit")

      assert show_live
             |> form("#vessel-form", vessel: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#vessel-form", vessel: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/vessels/#{vessel}")

      html = render(show_live)
      assert html =~ "Vessel updated successfully"
      assert html =~ "some updated name"
    end
  end
end