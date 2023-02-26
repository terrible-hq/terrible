defmodule Terrible.BudgetingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Terrible.Budgeting` context.
  """

  alias Terrible.Budgeting.{Book, Budget}
  alias Terrible.Utils

  @doc """
  Generate a book.
  """
  def book_fixture(attrs \\ %{}) do
    {:ok, book} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Book.create()

    book
  end

  @doc """
  Generate a Budget.
  """
  def budget_fixture(attrs \\ %{}) do
    current_month = Date.utc_today() |> Date.beginning_of_month()
    book_id = Map.get(attrs, :book_id) || book_fixture().id

    {:ok, budget} =
      attrs
      |> Enum.into(%{
        name: Utils.get_budget_name(current_month),
        month: current_month,
        book_id: book_id
      })
      |> Budget.create()

    budget
  end
end
