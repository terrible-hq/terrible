defmodule Terrible.Budgeting.CreateBook.Steps.CreateInitialBudgets do
  @moduledoc """
  Creates the initial budget records for the current and following month.
  """

  use Ash.Flow.Step

  alias Terrible.Budgeting.{Book, Budget}

  def run(%Book{} = book, _opts, _context) do
    current_month = Date.utc_today() |> Date.beginning_of_month()

    next_month =
      current_month
      |> Date.end_of_month()
      |> Date.add(1)

    budgets =
      Enum.map([current_month, next_month], fn month ->
        name =
          month
          |> Date.to_string()
          |> String.slice(0..6)
          |> String.replace("-", "")

        Budget.create!(%{
          name: name,
          month: month,
          book_id: book.id
        })
      end)

    {:ok, budgets}
  end
end
