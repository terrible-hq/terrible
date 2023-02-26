defmodule Terrible.Budgeting.CreateBook.Steps.CreateInitialBudgets do
  @moduledoc """
  Creates the initial budget records for the current and following month.
  """

  use Ash.Flow.Step

  alias Terrible.Budgeting.{Book, Budget}
  alias Terrible.Utils

  def run(%Book{} = book, _opts, _context) do
    current_month = Date.utc_today() |> Date.beginning_of_month()

    next_month =
      current_month
      |> Date.end_of_month()
      |> Date.add(1)

    budgets =
      Enum.map([current_month, next_month], fn month ->
        Budget.create!(%{
          name: Utils.get_budget_name(month),
          month: month,
          book_id: book.id
        })
      end)

    {:ok, budgets}
  end
end
