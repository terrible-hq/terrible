defmodule TerribleWeb.BudgetLive.CategoryTest do
  use TerribleWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "New Category" do
    setup %{conn: conn} do
      result = register_and_log_in_user(%{conn: conn})
      book = book_fixture(%{name: "Test Book"})
      book_user_fixture(book, result[:user])
      budget = budget_fixture(%{book_id: book.id})
      category = category_fixture(%{book_id: book.id, name: "Bills"})
      envelope = envelope_fixture(%{category_id: category.id, name: "Rent / Mortgage"})
      monthly_envelope_fixture(%{envelope_id: envelope.id, budget_id: budget.id})

      %{
        conn: result[:conn],
        user: result[:user],
        book: book,
        budget: budget
      }
    end

    test "New Category form submission with correct data creates a new Category", %{
      conn: conn,
      book: book,
      budget: budget
    } do
      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live |> element("a", "New Category") |> render_click() =~ "Create New Category"

      assert_patch(show_live, ~p"/books/#{book}/budgets/#{budget.name}/categories/new")

      assert show_live
             |> form("#category-form", category: %{name: "Test New Category"})
             |> render_submit()

      assert_patch(show_live, ~p"/books/#{book}/budgets/#{budget.name}")

      html = render(show_live)
      assert html =~ "Category created successfully"
      assert html =~ "Test New Category"
    end

    test "New Category form submission with blank data returns error", %{
      conn: conn,
      book: book,
      budget: budget
    } do
      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live |> element("a", "New Category") |> render_click() =~ "Create New Category"

      assert show_live
             |> form("#category-form", category: %{name: ""})
             |> render_change() =~ "is required"

      assert show_live
             |> form("#category-form", category: %{name: ""})
             |> render_submit() =~ "is required"
    end
  end

  describe "Edit Category" do
    setup %{conn: conn} do
      result = register_and_log_in_user(%{conn: conn})
      book = book_fixture(%{name: "Test Book"})
      book_user_fixture(book, result[:user])
      budget = budget_fixture(%{book_id: book.id})
      category = category_fixture(%{book_id: book.id, name: "Bills"})
      envelope = envelope_fixture(%{category_id: category.id, name: "Rent / Mortgage"})
      monthly_envelope_fixture(%{envelope_id: envelope.id, budget_id: budget.id})

      %{
        conn: result[:conn],
        user: result[:user],
        book: book,
        budget: budget
      }
    end

    test "Edit Category form submission with correct data updates existing Category", %{
      conn: conn,
      book: book,
      budget: budget
    } do
      category = category_fixture(%{name: "Existing Category", book_id: book.id})

      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live |> element("#categories-#{category.id} a", "Edit") |> render_click() =~
               "Edit Category"

      assert_patch(
        show_live,
        ~p"/books/#{book}/budgets/#{budget.name}/categories/#{category}/edit"
      )

      assert show_live
             |> form("#category-form", category: %{name: "Different Category"})
             |> render_submit()

      assert_patch(show_live, ~p"/books/#{book}/budgets/#{budget.name}")

      html = render(show_live)
      assert html =~ "Category updated successfully"
      assert html =~ "Different Category"
      refute html =~ "Existing Category"
    end

    test "Edit Category form submission with blank data returns error", %{
      conn: conn,
      book: book,
      budget: budget
    } do
      category = category_fixture(%{name: "Existing Category", book_id: book.id})

      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live |> element("#categories-#{category.id} a", "Edit") |> render_click() =~
               "Edit Category"

      assert show_live
             |> form("#category-form", category: %{name: ""})
             |> render_change() =~ "is required"

      assert show_live
             |> form("#category-form", category: %{name: ""})
             |> render_submit() =~ "is required"
    end
  end

  describe "Delete Category" do
    setup %{conn: conn} do
      result = register_and_log_in_user(%{conn: conn})
      book = book_fixture(%{name: "Test Book"})
      book_user_fixture(book, result[:user])
      budget = budget_fixture(%{book_id: book.id})
      category = category_fixture(%{book_id: book.id, name: "Bills"})
      envelope = envelope_fixture(%{category_id: category.id, name: "Rent / Mortgage"})
      monthly_envelope_fixture(%{envelope_id: envelope.id, budget_id: budget.id})

      %{
        conn: result[:conn],
        user: result[:user],
        book: book,
        budget: budget
      }
    end

    test "Clicking Delete button removes Category from page", %{
      conn: conn,
      book: book,
      budget: budget
    } do
      category = category_fixture(%{name: "Existing Category", book_id: book.id})

      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live |> element("#categories-#{category.id} a", "Delete") |> render_click()

      refute has_element?(show_live, "#categories-#{category.id}")
    end

    test "Delete button for Category vanishes from page when Category has existing Envelope records associated with it",
         %{conn: conn, book: book, budget: budget} do
      category = category_fixture(%{name: "Test Category", book_id: book.id})
      envelope = envelope_fixture(%{name: "Test Envelope", category_id: category.id})

      monthly_envelope_fixture(%{
        budget_id: budget.id,
        envelope_id: envelope.id,
        assigned_cents: 1234
      })

      {:ok, show_live, html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert html =~ "Test Category"
      assert html =~ "Test Envelope"
      assert html =~ "12.34"
      assert has_element?(show_live, "#categories-#{category.id} a", "Edit")
      refute has_element?(show_live, "#categories-#{category.id} a.delete_category", "Delete")
    end
  end
end
