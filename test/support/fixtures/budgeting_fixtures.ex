defmodule Terrible.BudgetingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Terrible.Budgeting` context.
  """

  alias Terrible.Budgeting.Book

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
end
