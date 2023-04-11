defmodule Terrible.Budgeting.MonthlyEnvelope do
  @moduledoc """
  A MonthlyEnvelope is the join table for the Envelope and Budget resource.
  It represents the budget that you have for a specific envelope in a given month.
  """

  use Ash.Resource, data_layer: AshPostgres.DataLayer

  alias Terrible.Budgeting.{Budget, Envelope}

  attributes do
    uuid_primary_key :id

    attribute :assigned_cents, :integer do
      default 0
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]

    read :by_budget_envelope_id do
      argument :budget_id, :uuid, allow_nil?: false
      argument :envelope_id, :uuid, allow_nil?: false

      get? true

      filter expr(budget_id == ^arg(:budget_id) and envelope_id == ^arg(:envelope_id))
    end

    create :create do
      primary? true
      upsert? true
      upsert_identity :unique_monthly_envelope

      argument :budget_id, :uuid do
        allow_nil? false
      end

      argument :envelope_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:budget_id, :budget, type: :append)
      change manage_relationship(:envelope_id, :envelope, type: :append)
    end
  end

  code_interface do
    define_for Terrible.Budgeting
    define :create, action: :create

    define :get_by_budget_envelope_id,
      args: [:budget_id, :envelope],
      action: :by_budget_envelope_id
  end

  relationships do
    belongs_to :budget, Budget do
      allow_nil? false
    end

    belongs_to :envelope, Envelope do
      allow_nil? false
    end
  end

  identities do
    identity :unique_monthly_envelope, [:budget_id, :envelope_id]
  end

  postgres do
    table "monthly_envelopes"
    repo Terrible.Repo

    references do
      reference :budget, on_delete: :delete
      reference :envelope, on_delete: :delete
    end
  end
end
