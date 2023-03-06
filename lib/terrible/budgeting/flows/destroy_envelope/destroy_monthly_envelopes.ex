defmodule Terrible.Budgeting.DestroyEnvelope.DestroyMonthlyEnvelopes do
  @moduledoc """
  Deletes all MonthlyEnvelope records associated with the given Envelope
  to ensure that no record gets orphaned before deleting the Envelope.
  """

  use Ash.Flow.Step

  import Ecto.Query

  alias Terrible.Budgeting.MonthlyEnvelope
  alias Terrible.Repo

  def run(envelope, _opts, _context) do
    MonthlyEnvelope
    |> where([me], me.envelope_id == ^envelope.id)
    |> Repo.delete_all()

    {:ok, envelope}
  end
end
