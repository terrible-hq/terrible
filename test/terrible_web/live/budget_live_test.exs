defmodule TerribleWeb.BudgetLiveTest do
  use TerribleWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Show" do
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
