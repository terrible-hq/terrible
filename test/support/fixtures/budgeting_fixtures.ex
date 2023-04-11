defmodule Terrible.BudgetingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Terrible.Budgeting` context.
  """

  alias Terrible.Budgeting.{Book, BookUser, Budget, Category, Envelope, MonthlyEnvelope}
  alias Terrible.Utils

  @doc """
  Generate a book.
  """
  def book_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "Some Book #{System.unique_integer([:positive])}}"
      })

    Ash.Seed.seed!(Book, attrs)
  end

  @doc """
  Generate a BookUser.
  """
  def book_user_fixture(book, user, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        book_id: book.id,
        user_id: user.id,
        role: :owner
      })

    Ash.Seed.seed!(BookUser, attrs)
  end

  @doc """
  Generate a Budget.
  """
  def budget_fixture(attrs \\ %{}) do
    current_month = Date.utc_today() |> Date.beginning_of_month()
    book_id = Map.get(attrs, :book_id) || book_fixture().id

    attrs =
      Enum.into(attrs, %{
        name: Utils.get_budget_name(current_month),
        month: current_month,
        book_id: book_id
      })

    Ash.Seed.seed!(Budget, attrs)
  end

  @doc """
  Generate a Category.
  """
  def category_fixture(attrs \\ %{}) do
    book_id = Map.get(attrs, :book_id) || book_fixture().id

    attrs =
      Enum.into(attrs, %{
        name: "Category #{System.unique_integer([:positive])}}",
        book_id: book_id
      })

    Ash.Seed.seed!(Category, attrs)
  end

  @doc """
  Generate an Envelope.
  """
  def envelope_fixture(attrs \\ %{}) do
    category_id = Map.get(attrs, :category_id) || category_fixture().id

    attrs =
      Enum.into(attrs, %{
        name: "Envelope #{System.unique_integer([:positive])}}",
        category_id: category_id
      })

    Ash.Seed.seed!(Envelope, attrs)
  end

  @doc """
  Generate a MonthlyEnvelope.
  """
  def monthly_envelope_fixture(attrs \\ %{}) do
    budget_id = Map.get(attrs, :budget_id) || budget_fixture().id
    envelope_id = Map.get(attrs, :envelope_id) || envelope_fixture().id

    attrs =
      Enum.into(attrs, %{
        budget_id: budget_id,
        envelope_id: envelope_id,
        assigned_cents: 0
      })

    Ash.Seed.seed!(MonthlyEnvelope, attrs)
  end
end
