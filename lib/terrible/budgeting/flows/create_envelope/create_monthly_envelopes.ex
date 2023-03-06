defmodule Terrible.Budgeting.CreateEnvelope.CreateMonthlyEnvelopes do
  @moduledoc """
  Creates MonthlyEnvelope records to backfill all of the Budget records that are
  associated with the Book in which the given Category record belongs to.
  """

  use Ash.Flow.Step

  alias Terrible.Budgeting.{Budget, MonthlyEnvelope}

  def run(input, _opts, _context) do
    category = input[:category]
    envelope = input[:envelope]

    monthly_envelopes =
      category
      |> Map.get(:book_id)
      |> Budget.list_by_book_id!()
      |> Enum.map(fn budget ->
        MonthlyEnvelope.create!(%{
          budget_id: budget.id,
          envelope_id: envelope.id
        })
      end)

    {:ok, monthly_envelopes}
  end
end
