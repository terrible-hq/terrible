defmodule Terrible.Accounting.TransactionEntry do
  @moduledoc """
  A TransactionEntry represents a single transaction that happens for an Envelope.

  Transaction Entries under a Transaction must total to zero due to the double-entry accounting rules.
  """

  alias Terrible.Accounting.Transaction
  alias Terrible.Budgeting.Envelope

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub]

  attributes do
    uuid_primary_key :id

    attribute :amount, :integer, allow_nil?: false
    attribute :cleared, :boolean, allow_nil?: false, default: false

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
  end

  relationships do
    belongs_to :transaction, Transaction do
      allow_nil? false
    end

    belongs_to :debit_envelope, Envelope do
      api Terrible.Budgeting
    end

    belongs_to :credit_envelope, Envelope do
      api Terrible.Budgeting
    end
  end

  postgres do
    table "transaction_entries"
    repo Terrible.Repo

    references do
      reference :transaction, on_delete: :delete
    end
  end
end
