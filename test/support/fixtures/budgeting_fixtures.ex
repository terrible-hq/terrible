defmodule Terrible.BudgetingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Terrible.Budgeting` context.
  """

  alias Terrible.Budgeting.{Book, Budget, Category, Envelope, MonthlyEnvelope}
  alias Terrible.Utils

  @doc """
  Generate a book.
  """
  def book_fixture(attrs \\ %{}) do
    {:ok, book} =
      attrs
      |> Enum.into(%{
        name: "Some Book"
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

  @doc """
  Generate a Category.
  """
  def category_fixture(attrs \\ %{}) do
    book_id = Map.get(attrs, :book_id) || book_fixture().id

    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: "Some Category",
        book_id: book_id
      })
      |> Category.create()

    category
  end

  @doc """
  Generate an Envelope.
  """
  def envelope_fixture(attrs \\ %{}) do
    category_id = Map.get(attrs, :category_id) || category_fixture().id

    {:ok, envelope} =
      attrs
      |> Enum.into(%{
        name: "Some Envelope",
        category_id: category_id
      })
      |> Envelope.create()

    envelope
  end

  @doc """
  Generate a MonthlyEnvelope.
  """
  def monthly_envelope_fixture(attrs \\ %{}) do
    budget_id = Map.get(attrs, :budget_id) || budget_fixture().id
    envelope_id = Map.get(attrs, :envelope_id) || envelope_fixture().id

    {:ok, monthly_envelope} =
      attrs
      |> Enum.into(%{
        budget_id: budget_id,
        envelope_id: envelope_id,
        assigned_cents: 0
      })
      |> MonthlyEnvelope.create()

    monthly_envelope
  end
end
