defmodule TerribleWeb.BookLiveTest do
  use TerribleWeb.ConnCase

  import Phoenix.LiveViewTest
  import Terrible.BudgetingFixtures

  @create_attrs %{name: "Test Book"}
  @update_attrs %{name: "Test Book Updated"}
  @invalid_attrs %{name: nil}

  defp create_book(_) do
    book = book_fixture()
    %{book: book}
  end

  describe "Index" do
    setup [:create_book]

    test "lists all books", %{conn: conn, book: book} do
      {:ok, _index_live, html} = live(conn, ~p"/books")

      assert html =~ "Listing Books"
      assert html =~ book.name
    end

    test "new form submission with correct data saves new book", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("a", "New Book") |> render_click() =~
               "New Book"

      assert_patch(index_live, ~p"/books/new")

      {:ok, _, html} =
        index_live
        |> form("#book-form", book: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/books")

      assert html =~ "Book created successfully"
      assert html =~ "Test Book"
    end

    test "new form submission with blank data returns error", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("a", "New Book") |> render_click() =~
               "New Book"

      assert index_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_submit() =~ "is required"
    end

    test "edit form submission with correct data updates book in listing", %{
      conn: conn,
      book: book
    } do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("#books-#{book.id} a", "Edit") |> render_click() =~
               "Edit Book"

      assert_patch(index_live, ~p"/books/#{book}/edit")

      {:ok, _, html} =
        index_live
        |> form("#book-form", book: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/books")

      assert html =~ "Book updated successfully"
      assert html =~ "Test Book Updated"
    end

    test "edit form submission with blank data returns error", %{conn: conn, book: book} do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("#books-#{book.id} a", "Edit") |> render_click() =~
               "Edit Book"

      assert index_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_submit() =~ "is required"
    end

    test "clicking delete button deletes book in listing", %{conn: conn, book: book} do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("#books-#{book.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#book-#{book.id}")
    end
  end

  describe "Show" do
    setup [:create_book]

    test "displays book", %{conn: conn, book: book} do
      {:ok, _show_live, html} = live(conn, ~p"/books/#{book}")

      assert html =~ "Show Book"
      assert html =~ book.name
    end

    test "edit form submission with correct data updates book", %{conn: conn, book: book} do
      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Book"

      assert_patch(show_live, ~p"/books/#{book}/show/edit")

      {:ok, _, html} =
        show_live
        |> form("#book-form", book: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/books/#{book}")

      assert html =~ "Book updated successfully"
      assert html =~ "Test Book Updated"
    end

    test "edit form submission with blank data returns error", %{conn: conn, book: book} do
      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Book"

      assert show_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_submit() =~ "is required"
    end
  end
end
