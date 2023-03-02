defmodule Terrible.Budgeting.CreateBudget do
  @moduledoc """
  A flow module for creating a new Budget and all the
  MonthlyEnvelope records it needs to function properly.
  """

  use Ash.Flow, otp_app: :terrible

  alias Terrible.Budgeting.Budget
  alias Terrible.Budgeting.CreateBudget.CreateMonthlyEnvelopes

  flow do
    api Terrible.Budgeting

    description "A flow module for creating a new Budget and all the MonthlyEnvelope records it needs to function properly."

    argument :name, :string do
      allow_nil? false
    end

    argument :month, :date do
      allow_nil? false
    end

    argument :book_id, :uuid do
      allow_nil? false
    end

    returns :create_budget
  end

  steps do
    create :create_budget, Budget, :create do
      input %{
        name: arg(:name),
        month: arg(:month),
        book_id: arg(:book_id)
      }
    end

    custom :create_monthly_envelopes, CreateMonthlyEnvelopes do
      input %{
        budget: result(:create_budget),
        book_id: arg(:book_id)
      }
    end
  end
end
