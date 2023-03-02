defmodule Terrible.Budgeting.CreateBudget.CreateMonthlyEnvelopes do
  @moduledoc """
  Creates a Budget record and all of its MonthlyEnvelope associations.
  MonthlyEnvelope records are based on the Book record that the given
  Budget record belongs to.
  """

  use Ash.Flow.Step

  require Ash.Query

  alias Terrible.Budgeting
  alias Terrible.Budgeting.{Category, MonthlyEnvelope}

  def run(input, _opts, _context) do
    book_id = input[:book_id]
    budget = input[:budget]

    monthly_envelopes =
      Category
      |> Ash.Query.for_read(:by_book_id, %{id: book_id})
      |> Ash.Query.load(:envelopes)
      |> Budgeting.read!()
      |> Enum.reduce(Map.new(), fn category, acc ->
        result =
          Enum.map(category.envelopes, fn envelope ->
            MonthlyEnvelope.create!(%{
              budget_id: budget.id,
              envelope_id: envelope.id
            })
          end)

        Map.put(acc, category.id, result)
      end)

    {:ok, monthly_envelopes}
  end
end
