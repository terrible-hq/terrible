defmodule Terrible.Budgeting.Book.Changes.CreateRelatedRecords do
  @moduledoc """
  Creates the related records for a new book.
  """

  use Ash.Resource.Change

  alias Terrible.Budgeting.{BookUser, Budget, Category}
  alias Terrible.Utils

  def change(changeset, _opts, %{actor: actor}) do
    Ash.Changeset.after_action(changeset, fn _, result ->
      create_book_owner(result.id, actor.id)
      create_budgets(result.id)
      create_categories(result.id)

      {:ok, result}
    end)
  end

  defp create_book_owner(book_id, user_id) do
    BookUser.create!(
      %{
        book_id: book_id,
        user_id: user_id,
        role: :owner
      },
      return_notifications?: true
    )
  end

  defp create_budgets(book_id) do
    current_month = Date.utc_today() |> Date.beginning_of_month()
    next_month = current_month |> Date.end_of_month() |> Date.add(1)

    Enum.map([current_month, next_month], fn month ->
      Budget.create!(
        %{
          name: Utils.get_budget_name(month),
          month: month,
          book_id: book_id
        },
        return_notifications?: true
      )
    end)
  end

  defp create_categories(book_id) do
    Enum.map(default_categories_and_envelopes_list(book_id), fn content ->
      Category.create!(content, return_notifications?: true)
    end)
  end

  def default_categories_and_envelopes_list(book_id) do
    [
      %{
        name: "System",
        book_id: book_id,
        type: :system,
        envelopes: [
          %{name: "Ready to Assign", book_id: book_id, type: :unassigned}
        ]
      },
      %{
        name: "Bills",
        book_id: book_id,
        envelopes: [
          %{name: "Rent / Mortgage", book_id: book_id},
          %{name: "Electric", book_id: book_id},
          %{name: "Water", book_id: book_id},
          %{name: "Internet", book_id: book_id},
          %{name: "Cellphone", book_id: book_id}
        ]
      },
      %{
        name: "Frequent",
        book_id: book_id,
        envelopes: [
          %{name: "Groceries", book_id: book_id},
          %{name: "Eating Out", book_id: book_id},
          %{name: "Transportation Out", book_id: book_id}
        ]
      },
      %{
        name: "Non-Monthly",
        book_id: book_id,
        envelopes: [
          %{name: "Home Maintenance", book_id: book_id},
          %{name: "Auto Maintenance", book_id: book_id},
          %{name: "Gifts", book_id: book_id}
        ]
      },
      %{
        name: "Goals",
        book_id: book_id,
        envelopes: [
          %{name: "Vacation", book_id: book_id},
          %{name: "Education", book_id: book_id},
          %{name: "Home Improvement", book_id: book_id}
        ]
      },
      %{
        name: "Quality of Life",
        book_id: book_id,
        envelopes: [
          %{name: "Hobbies", book_id: book_id},
          %{name: "Entertainment", book_id: book_id},
          %{name: "Health & Wellness", book_id: book_id}
        ]
      }
    ]
  end
end
