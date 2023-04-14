defmodule Terrible.Budgeting.Envelope.Changes.CreateMonthlyEnvelopes do
  @moduledoc """
  Backfills the MonthlyEnvelopes for a new envelope.
  """

  use Ash.Resource.Change

  alias Terrible.Budgeting
  alias Terrible.Budgeting.MonthlyEnvelope

  def change(changeset, _opts, _actor) do
    Ash.Changeset.after_action(changeset, fn _, result ->
      with {:ok, envelope} <- Budgeting.load(result, category: [book: :budgets]) do
        Enum.each(envelope.category.book.budgets, fn budget ->
          MonthlyEnvelope.create(
            %{
              envelope_id: envelope.id,
              budget_id: budget.id
            },
            return_notifications?: true
          )
        end)
      end

      {:ok, result}
    end)
  end
end
