defmodule VesseltrackingLiveWeb.TrailLiveTest do
  use VesseltrackingLiveWeb.ConnCase

  import Phoenix.LiveViewTest
  import Support.Fixtures

  @create_attrs %{day: "2024-03-12", steps: [], tracking_id: "some tracking_id"}
  @update_attrs %{day: "2024-03-13", steps: [], tracking_id: "some updated tracking_id"}
  @invalid_attrs %{day: nil, steps: [], tracking_id: nil}

  defp create_trail(_) do
    trail = trail_fixture()
    %{trail: trail}
  end

  describe "Index" do
    setup [:create_trail]

    test "lists all trails", %{conn: conn, trail: trail} do
      {:ok, _index_live, html} = live(conn, ~p"/trails")

      assert html =~ "Listing Trails"
      assert html =~ trail.tracking_id
    end

    test "saves new trail", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/trails")

      assert index_live |> element("a", "New Trail") |> render_click() =~
               "New Trail"

      assert_patch(index_live, ~p"/trails/new")

      assert index_live
             |> form("#trail-form", trail: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#trail-form", trail: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/trails")

      html = render(index_live)
      assert html =~ "Trail created successfully"
      assert html =~ "some tracking_id"
    end

    test "updates trail in listing", %{conn: conn, trail: trail} do
      {:ok, index_live, _html} = live(conn, ~p"/trails")

      assert index_live |> element("#trails-#{trail.id} a", "Edit") |> render_click() =~
               "Edit Trail"

      assert_patch(index_live, ~p"/trails/#{trail}/edit")

      assert index_live
             |> form("#trail-form", trail: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#trail-form", trail: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/trails")

      html = render(index_live)
      assert html =~ "Trail updated successfully"
      assert html =~ "some updated tracking_id"
    end

    test "deletes trail in listing", %{conn: conn, trail: trail} do
      {:ok, index_live, _html} = live(conn, ~p"/trails")

      assert index_live |> element("#trails-#{trail.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#trails-#{trail.id}")
    end
  end

  describe "Show" do
    setup [:create_trail]

    test "displays trail", %{conn: conn, trail: trail} do
      {:ok, _show_live, html} = live(conn, ~p"/trails/#{trail}")

      assert html =~ "Show Trail"
      assert html =~ trail.tracking_id
    end

    test "updates trail within modal", %{conn: conn, trail: trail} do
      {:ok, show_live, _html} = live(conn, ~p"/trails/#{trail}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Trail"

      assert_patch(show_live, ~p"/trails/#{trail}/show/edit")

      assert show_live
             |> form("#trail-form", trail: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#trail-form", trail: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/trails/#{trail}")

      html = render(show_live)
      assert html =~ "Trail updated successfully"
      assert html =~ "some updated tracking_id"
    end
  end
end
