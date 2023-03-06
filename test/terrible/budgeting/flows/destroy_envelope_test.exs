defmodule Terrible.Budgeting.DestroyEnvelopeTest do
  use Terrible.DataCase

  require Ash.Query

  alias Terrible.Budgeting
  alias Terrible.Budgeting.DestroyEnvelope
  alias Terrible.Budgeting.MonthlyEnvelope

  describe "run" do
    setup [:create_fixtures]

    test "Deletes Envelope and its associated MonthlyEnvelopes", %{envelope: envelope} do
      initial_monthly_envelopes =
        MonthlyEnvelope
        |> Ash.Query.for_read(:read)
        |> Budgeting.read!()

      assert Enum.count(initial_monthly_envelopes) == 1

      DestroyEnvelope.run!(envelope.id)

      monthly_envelopes =
        MonthlyEnvelope
        |> Ash.Query.for_read(:read)
        |> Budgeting.read!()

      assert Enum.empty?(monthly_envelopes)
    end
  end

  defp create_fixtures(_) do
    book = book_fixture(name: "Test Book")

    budget =
      budget_fixture(%{
        name: "202303",
        month: ~D[2023-03-04],
        book_id: book.id
      })

    category =
      category_fixture(%{
        name: "Test Category",
        book_id: book.id
      })

    envelope =
      envelope_fixture(%{
        name: "Test Envelope",
        category_id: category.id
      })

    monthly_envelope_fixture(%{
      budget_id: budget.id,
      envelope_id: envelope.id,
      assigned_cents: 1234
    })

    %{envelope: envelope}
  end
end
