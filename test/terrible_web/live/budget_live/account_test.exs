defmodule TerribleWeb.BudgetLive.AccountTest do
  use TerribleWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "New Account" do
    setup %{conn: conn} do
      result = register_and_log_in_user(%{conn: conn})
      book = book_fixture(%{name: "Test Book"})
      book_user_fixture(book, result[:user])
      budget = budget_fixture(%{book_id: book.id})
      account_type = account_type_fixture(%{name: "Savings"})

      %{
        conn: result[:conn],
        user: result[:user],
        account_type: account_type,
        book: book,
        budget: budget
      }
    end

    test "New Account form submission with correct data creates a new Account", %{
      conn: conn,
      account_type: account_type,
      book: book,
      budget: budget
    } do
      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live |> element("#sidebar a", "Add Account") |> render_click() =~
               "Create New Account"

      assert_patch(show_live, ~p"/books/#{book}/budgets/#{budget.name}/accounts/new")

      assert show_live
             |> form("#account-form",
               account: %{name: "Test New Account", account_type_id: account_type.id}
             )
             |> render_submit()

      assert_patch(show_live, ~p"/books/#{book}/budgets/#{budget.name}")

      html = render(show_live)
      assert html =~ "Account created successfully"
      assert html =~ "Test New Account"
    end

    test "New Account form submission with blank data returns error", %{
      conn: conn,
      book: book,
      budget: budget
    } do
      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live |> element("#sidebar a", "Add Account") |> render_click() =~
               "Create New Account"

      assert show_live
             |> form("#account-form", account: %{name: ""})
             |> render_change() =~ "is required"
    end
  end

  describe "Edit Category" do
    setup %{conn: conn} do
      result = register_and_log_in_user(%{conn: conn})
      book = book_fixture(%{name: "Test Book"})
      book_user_fixture(book, result[:user])
      budget = budget_fixture(%{book_id: book.id})
      account_type = account_type_fixture(%{name: "Savings"})

      %{
        conn: result[:conn],
        user: result[:user],
        book: book,
        budget: budget,
        account_type: account_type
      }
    end

    test "Edit Account form submission with correct data updates existing Account", %{
      conn: conn,
      book: book,
      budget: budget,
      account_type: account_type
    } do
      account =
        account_fixture(%{
          name: "Existing Account",
          book_id: book.id,
          account_type_id: account_type.id
        })

      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live
             |> element(
               "#sidebar #accounts-#{account.id} a",
               "Edit Account - #{account.name}"
             )
             |> render_click() =~
               "Edit Account"

      assert_patch(
        show_live,
        ~p"/books/#{book}/budgets/#{budget.name}/accounts/#{account}/edit"
      )

      assert show_live
             |> form("#account-form", account: %{name: "Different Account"})
             |> render_submit()

      assert_patch(show_live, ~p"/books/#{book}/budgets/#{budget.name}")

      html = render(show_live)
      assert html =~ "Account updated successfully"
      assert html =~ "Different Account"
      refute html =~ "Existing Account"
    end

    test "Edit Account form submission with blank data returns error", %{
      conn: conn,
      book: book,
      budget: budget,
      account_type: account_type
    } do
      account =
        account_fixture(%{
          name: "Existing Account",
          book_id: book.id,
          account_type_id: account_type.id
        })

      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live
             |> element("#sidebar #accounts-#{account.id} a", "Edit")
             |> render_click() =~
               "Edit Account"

      assert show_live
             |> form("#account-form", account: %{name: ""})
             |> render_change() =~ "is required"
    end
  end

  describe "Delete Account" do
    setup %{conn: conn} do
      result = register_and_log_in_user(%{conn: conn})
      book = book_fixture(%{name: "Test Book"})
      book_user_fixture(book, result[:user])
      budget = budget_fixture(%{book_id: book.id})
      account_type = account_type_fixture(%{name: "Savings"})

      %{
        conn: result[:conn],
        user: result[:user],
        book: book,
        budget: budget,
        account_type: account_type
      }
    end

    test "Clicking Delete button removes Account from page", %{
      conn: conn,
      book: book,
      budget: budget,
      account_type: account_type
    } do
      account =
        account_fixture(%{
          name: "Existing Account",
          book_id: book.id,
          account_type_id: account_type.id
        })

      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}/budgets/#{budget.name}")

      assert show_live
             |> element("#sidebar #accounts-#{account.id} a", "Delete")
             |> render_click()

      refute has_element?(show_live, "#accounts-#{account.id}")
    end
  end
end
