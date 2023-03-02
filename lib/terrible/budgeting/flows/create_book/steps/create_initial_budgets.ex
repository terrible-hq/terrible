defmodule Terrible.Budgeting.CreateBook.Steps.CreateInitialBudgets do
  @moduledoc """
  Creates the initial budget records for the current and following month.
  """

  use Ash.Flow.Step

  alias Terrible.Budgeting.CreateBudget
  alias Terrible.Utils

  def run(input, _opts, _context) do
    book = input[:book]

    current_month = Date.utc_today() |> Date.beginning_of_month()

    next_month =
      current_month
      |> Date.end_of_month()
      |> Date.add(1)

    budgets =
      Enum.map([current_month, next_month], fn month ->
        CreateBudget.run!(
          Utils.get_budget_name(month),
          month,
          book.id
        )
      end)

    {:ok, budgets}
  end
end
