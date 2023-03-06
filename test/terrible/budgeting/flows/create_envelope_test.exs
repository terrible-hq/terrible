defmodule Terrible.Budgeting.CreateEnvelopeTest do
  use Terrible.DataCase

  alias Terrible.Budgeting.CreateEnvelope

  describe "run" do
    setup [:create_essential_fixtures]

    test "with valid data creates an Envelope and a MonthlyEnvelope for each Budget the given Book has",
         %{category: category} do
      envelope =
        "New Category"
        |> CreateEnvelope.run!(category.id)
        |> Map.get(:result)

      assert envelope.name == "New Category"
      assert envelope.category_id == category.id
    end

    test "with blank data returns error" do
      assert_raise Ash.Error.Invalid, ~r/attribute name is required/, fn ->
        CreateEnvelope.run!(nil, nil)
      end
    end
  end

  defp create_essential_fixtures(_) do
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

    %{
      book: book,
      budget: budget,
      category: category
    }
  end
end
