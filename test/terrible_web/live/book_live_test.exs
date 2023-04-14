defmodule TerribleWeb.BookLiveTest do
  use TerribleWeb.ConnCase

  import Phoenix.LiveViewTest

  @create_attrs %{name: "Test Book"}
  @update_attrs %{name: "Test Book Updated"}
  @invalid_attrs %{name: nil}

  describe "with existing books" do
    setup %{conn: conn} do
      result = register_and_log_in_user(%{conn: conn})
      book = book_fixture(%{name: "Test Book"})
      book_user_fixture(book, result[:user])

      %{
        conn: result[:conn],
        user: result[:user],
        book: book
      }
    end

    test "lists all books", %{conn: conn, book: book} do
      {:ok, _index_live, html} = live(conn, ~p"/books")

      assert html =~ "Listing Books"
      assert html =~ book.name
    end

    test "edit form submission with correct data updates book in listing", %{
      conn: conn,
      book: book
    } do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("#books-#{book.id} a", "Edit") |> render_click() =~
               "Edit Book"

      assert_patch(index_live, ~p"/books/#{book}/edit")

      assert index_live
             |> form("#book-form", book: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/books")

      html = render(index_live)
      assert html =~ "Book updated successfully"
      assert html =~ "Test Book Updated"
    end

    test "edit form submission with blank data returns error", %{conn: conn, book: book} do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("#books-#{book.id} a", "Edit") |> render_click() =~
               "Edit Book"

      assert index_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_change() =~ "is required"

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

  describe "without existing Book" do
    setup [:register_and_log_in_user]

    test "new form submission with correct data saves new book", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("a", "New Book") |> render_click() =~
               "New Book"

      assert_patch(index_live, ~p"/books/new")

      assert index_live
             |> form("#book-form", book: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/books")

      html = render(index_live)
      assert html =~ "Book created successfully"
      assert html =~ "Test Book"
    end

    test "new form submission with blank data returns error", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("a", "New Book") |> render_click() =~
               "New Book"

      assert index_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_change() =~ "is required"

      assert index_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_submit() =~ "is required"
    end
  end
end
