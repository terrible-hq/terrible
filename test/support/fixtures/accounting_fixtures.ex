defmodule Terrible.AccountingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Terrible.Accounting` context.
  """

  alias Terrible.Accounting.{Account, AccountType}
  alias Terrible.BudgetingFixtures

  def account_type_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "Some Account Type",
        type: :asset
      })

    Ash.Seed.seed!(AccountType, attrs)
  end

  def account_fixture(attrs \\ %{}) do
    book_id = Map.get(attrs, :book_id) || BudgetingFixtures.book_fixture().id
    account_type_id = Map.get(attrs, :account_type_id) || account_type_fixture().id

    attrs =
      Enum.into(attrs, %{
        name: "Account #{System.unique_integer([:positive])}}",
        book_id: book_id,
        account_type_id: account_type_id
      })

    Ash.Seed.seed!(Account, attrs)
  end
end
