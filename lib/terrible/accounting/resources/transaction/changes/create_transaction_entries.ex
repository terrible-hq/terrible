defmodule Terrible.Accounting.Transaction.Changes.CreateTransactionEntries do
  @moduledoc """
  Creates the TransactionEntry records for the Transaction.
  """

  use Ash.Resource.Change

  alias Terrible.Accounting.TransactionEntry

  def change(changeset, _opts, _context) do
    require IEx; IEx.pry
    Ash.Changeset.after_action(changeset, fn _, result ->
      {:ok, result}
    end)
  end
end
