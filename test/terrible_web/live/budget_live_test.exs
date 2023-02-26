defmodule TerribleWeb.BudgetLiveTest do
  use TerribleWeb.ConnCase

  import Phoenix.LiveViewTest
  import Terrible.BudgetingFixtures

  defp create_fixtures(_) do
    book = book_fixture(name: "Test Book")

    budget =
      budget_fixture(%{
        name: "202302",
        month: ~D[2023-02-26],
        book_id: book.id
      })

    %{book: book, budget: budget}
  end

  describe "Show" do
    setup [:create_fixtures]

    test "displays page", %{conn: conn, book: book} do
      {:ok, _show_live, html} = live(conn, ~p"/books/#{book}/budgets/202302")

      assert html =~ "Your Budget - Test Book"
    end
  end
end
