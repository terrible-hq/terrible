defmodule Terrible.Budgeting.CreateBook do
  @moduledoc """
  A flow module for creating a new Book and everything
  it needs for a user to get started.
  """

  use Ash.Flow, otp_app: :terrible

  alias Terrible.Budgeting.Book

  alias Terrible.Budgeting.CreateBook.Steps.{
    CreateInitialBudgets,
    CreateInitialCategoriesEnvelopes
  }

  flow do
    api Terrible.Budgeting

    description "A flow module for creating a new Book and everything it needs for a user to get started."

    argument :name, :string do
      allow_nil? false
    end

    returns :create_book
  end

  steps do
    create :create_book, Book, :create do
      input %{name: arg(:name)}
    end

    custom :create_initial_categories_and_envelopes, CreateInitialCategoriesEnvelopes do
      input result(:create_book)
    end

    custom :create_initial_budgets, CreateInitialBudgets do
      input %{
        book: result(:create_book),
        categories_envelopes: result(:create_initial_categories_and_envelopes)
      }
    end
  end
end
