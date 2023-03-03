defmodule TerribleWeb.BudgetLiveTest do
  use TerribleWeb.ConnCase

  import Phoenix.LiveViewTest
  import Terrible.BudgetingFixtures

  describe "Show - General" do
    setup [:create_all_fixtures]

    test "displays page", %{conn: conn, book: book, budget: budget, category: category} do
      envelope = envelope_fixture(%{name: "Test Envelope 2", category_id: category.id})

      monthly_envelope_fixture(%{
        budget_id: budget.id,
        envelope_id: envelope.id,
        assigned_cents: -4321
      })

      {:ok, _show_live, html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert html =~ "Your Budget - Test Book"
      assert html =~ "Test Category"
      assert html =~ "Test Envelope"
      assert html =~ "12.34"
      assert html =~ "Test Envelope 2"
      assert html =~ "-43.21"
    end
  end

  describe "Show - Categories" do
    setup [:create_essential_fixtures]

    test "New Category form submission with correct data creates a new Category", %{
      conn: conn,
      book: book,
      budget: budget
    } do
      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live |> element("a", "New Category") |> render_click() =~ "Create New Category"

      assert_patch(show_live, ~p"/books/#{book}/budgets/#{budget.name}/categories/new")

      {:ok, _show_live, html} =
        show_live
        |> form("#category-form", category: %{name: "Test New Category"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/books/#{book}/budgets/#{budget.name}")

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

      {:ok, _show_live, html} =
        show_live
        |> form("#category-form", category: %{name: "Different Category"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/books/#{book}/budgets/#{budget.name}")

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
      refute has_element?(show_live, "#categories-#{category.id} a", "Delete")
    end
  end

  defp create_essential_fixtures(_) do
    book = book_fixture(name: "Test Book")

    budget =
      budget_fixture(%{
        name: "202302",
        month: ~D[2023-02-26],
        book_id: book.id
      })

    category =
      category_fixture(%{
        name: "Test Category",
        book_id: book.id
      })

    %{
      book: book,
      budget: budget,
      category: category
    }
  end

  defp create_all_fixtures(_) do
    essential_fixtures = create_essential_fixtures(nil)

    budget = Map.get(essential_fixtures, :budget)
    category = Map.get(essential_fixtures, :category)

    envelope =
      envelope_fixture(%{
        name: "Test Envelope",
        category_id: category.id
      })

    monthly_envelope =
      monthly_envelope_fixture(%{
        budget_id: budget.id,
        envelope_id: envelope.id,
        assigned_cents: 1234
      })

    Map.merge(essential_fixtures, %{
      envelope: envelope,
      monthly_envelope: monthly_envelope
    })
  end
end
