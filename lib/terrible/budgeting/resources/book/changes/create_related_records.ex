defmodule Terrible.Budgeting.Book.Changes.CreateRelatedRecords do
  @moduledoc """
  Creates the related records for a new book.
  """

  use Ash.Resource.Change

  alias Terrible.Budgeting.{BookUser, Budget, Category}
  alias Terrible.Utils

  @list_of_categories_and_envelopes [
    %{
      category: "Bills",
      envelopes: [
        "Rent / Mortgage",
        "Electric",
        "Water",
        "Internet",
        "Cellphone"
      ]
    },
    %{
      category: "Frequent",
      envelopes: [
        "Groceries",
        "Eating Out",
        "Transportation"
      ]
    },
    %{
      category: "Non-Monthly",
      envelopes: [
        "Home Maintenance",
        "Auto Maintenance",
        "Gifts"
      ]
    },
    %{
      category: "Goals",
      envelopes: [
        "Vacation",
        "Education",
        "Home Improvement"
      ]
    },
    %{
      category: "Quality of Life",
      envelopes: [
        "Hobbies",
        "Entertainment",
        "Health & Wellness"
      ]
    }
  ]

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
    Enum.map(@list_of_categories_and_envelopes, fn content ->
      Category.create!(
        %{
          book_id: book_id,
          name: content[:category],
          envelopes: content[:envelopes]
        },
        return_notifications?: true
      )
    end)
  end
end
