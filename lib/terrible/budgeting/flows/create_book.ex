defmodule Terrible.Budgeting.CreateBook do
  @moduledoc """
  A flow module for creating a new Book and everything
  it needs for a user to get started.
  """

  use Ash.Flow, otp_app: :terrible

  alias Terrible.Budgeting.Book
  alias Terrible.Budgeting.CreateBook.Steps.CreateInitialBudgets

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

    custom :create_initial_budgets, CreateInitialBudgets do
      input result(:create_book)
    end
  end
end