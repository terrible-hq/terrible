defmodule Terrible.Budgeting.CreateEnvelope do
  @moduledoc """
  A flow module for creating a new Envelope and MonthlyEnvelope records
  for all the Budget records that exist for the associated Book.
  """

  use Ash.Flow, otp_app: :terrible

  alias Terrible.Budgeting.{Category, Envelope}
  alias Terrible.Budgeting.CreateEnvelope.CreateMonthlyEnvelopes

  flow do
    api Terrible.Budgeting

    description "A flow module for creating a new Envelope and MonthlyEnvelope records for all the Budget records that exist for the associated Book"

    argument :name, :string do
      allow_nil? false
    end

    argument :category_id, :uuid do
      allow_nil? false
    end

    returns :create_envelope
  end

  steps do
    read :get_category, Category, :by_id do
      input %{
        id: arg(:category_id)
      }
    end

    create :create_envelope, Envelope, :create do
      input %{
        name: arg(:name),
        category_id: arg(:category_id)
      }
    end

    custom :create_monthly_envelopes, CreateMonthlyEnvelopes do
      input %{
        category: result(:get_category),
        envelope: result(:create_envelope)
      }
    end
  end
end
