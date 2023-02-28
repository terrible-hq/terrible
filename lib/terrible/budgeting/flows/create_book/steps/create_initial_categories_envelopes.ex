defmodule Terrible.Budgeting.CreateBook.Steps.CreateInitialCategoriesEnvelopes do
  @moduledoc """
  Creates the initial categories and envelopes to get the user started.
  """

  use Ash.Flow.Step

  alias Terrible.Budgeting.{Book, Category, Envelope}

  @content [
    %{
      category: "Bills",
      envelopes: [
        "Rent / Mortgage",
        "Electric",
        "Water",
        "Internet",
        "Cellphone"
      ]
    },
    %{
      category: "Frequent",
      envelopes: [
        "Groceries",
        "Eating Out",
        "Transportation"
      ]
    },
    %{
      category: "Non-Monthly",
      envelopes: [
        "Home Maintenance",
        "Auto Maintenance",
        "Gifts"
      ]
    },
    %{
      category: "Goals",
      envelopes: [
        "Vacation",
        "Education",
        "Home Improvement"
      ]
    },
    %{
      category: "Quality of Life",
      envelopes: [
        "Hobbies",
        "Entertainment",
        "Health & Wellness"
      ]
    }
  ]

  def run(%Book{} = book, _opts, _context) do
    content =
      Enum.map(@content, fn entry ->
        category = Category.create!(%{name: entry.category, book_id: book.id})

        envelopes =
          Enum.map(entry.envelopes, fn name ->
            Envelope.create!(%{name: name, category_id: category.id})
          end)

        %{category: category, envelopes: envelopes}
      end)

    {:ok, content}
  end
end
