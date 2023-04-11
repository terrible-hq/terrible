defmodule TerribleWeb.BudgetLiveTest do
  use TerribleWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Show" do
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

    test "displays page", %{conn: conn, book: book, budget: budget} do
      {:ok, _show_live, html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert html =~ "Your Budget - Test Book"
      assert html =~ "Bills"
      assert html =~ "Rent / Mortgage"
      assert html =~ "0.0"
    end
  end
end
