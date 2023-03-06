defmodule TerribleWeb.BudgetLive.EnvelopeTest do
  use TerribleWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "New Envelope" do
    setup [:create_essential_fixtures]

    test "New Envelope form submission with correct data creates a new Envelope", %{
      conn: conn,
      book: book,
      budget: budget,
      category: category
    } do
      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live |> element("a", "New Envelope") |> render_click() =~ "Create New Envelope"

      assert_patch(
        show_live,
        ~p"/books/#{book}/budgets/#{budget.name}/categories/#{category}/envelopes/new"
      )

      {:ok, _show_live, html} =
        show_live
        |> form("#envelope-form", envelope: %{name: "Test New Envelope"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert html =~ "Envelope created successfully"
      assert html =~ "Test New Envelope"
    end

    test "New Envelope form submission with blank data returns error", %{
      conn: conn,
      book: book,
      budget: budget
    } do
      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live |> element("a", "New Envelope") |> render_click() =~ "Create New Envelope"

      assert show_live
             |> form("#envelope-form", envelope: %{name: ""})
             |> render_change() =~ "is required"

      assert show_live
             |> form("#envelope-form", envelope: %{name: ""})
             |> render_submit() =~ "is required"
    end
  end

  describe "Edit Envelope" do
    setup [:create_essential_fixtures]

    test "Edit Envelope form submission with correct data updates existing Envelope", %{
      conn: conn,
      book: book,
      budget: budget,
      category: category
    } do
      envelope = envelope_fixture(%{name: "Existing Envelope", category_id: category.id})

      monthly_envelope_fixture(%{
        budget_id: budget.id,
        envelope_id: envelope.id,
        assigned_cents: 1234
      })

      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live |> element("#envelopes-#{envelope.id} a", "Edit") |> render_click() =~
               "Edit Envelope"

      assert_patch(
        show_live,
        ~p"/books/#{book}/budgets/#{budget.name}/categories/#{category}/envelopes/#{envelope}/edit"
      )

      {:ok, _show_live, html} =
        show_live
        |> form("#envelope-form", envelope: %{name: "Different Envelope"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert html =~ "Envelope updated successfully"
      assert html =~ "Different Envelope"
      refute html =~ "Existing Envelope"
    end

    test "Edit Envelope form submission with blank data returns error", %{
      conn: conn,
      book: book,
      budget: budget,
      category: category
    } do
      envelope = envelope_fixture(%{name: "Existing Envelope", category_id: category.id})

      monthly_envelope_fixture(%{
        budget_id: budget.id,
        envelope_id: envelope.id,
        assigned_cents: 1234
      })

      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live |> element("#envelopes-#{envelope.id} a", "Edit") |> render_click() =~
               "Edit Envelope"

      assert show_live
             |> form("#envelope-form", envelope: %{name: ""})
             |> render_change() =~ "is required"

      assert show_live
             |> form("#envelope-form", envelope: %{name: ""})
             |> render_submit() =~ "is required"
    end
  end

  describe "Delete Envelope" do
    setup [:create_essential_fixtures]

    test "Clicking Delete button removes Envelope from page", %{
      conn: conn,
      book: book,
      budget: budget,
      category: category
    } do
      envelope = envelope_fixture(%{name: "Existing Envelope", category_id: category.id})

      monthly_envelope_fixture(%{
        budget_id: budget.id,
        envelope_id: envelope.id,
        assigned_cents: 1234
      })

      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live |> element("#envelopes-#{envelope.id} a", "Delete") |> render_click()

      refute has_element?(show_live, "#envelopes-#{envelope.id}")
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
end
