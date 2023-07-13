defmodule Terrible.Accounting.Transaction do
  @moduledoc """
  A Transaction is what groups TransactionEntries together.
  """

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub]

  alias Terrible.Accounting.TransactionEntry
  alias Terrible.Accounting.Transaction.Changes.CreateTransactionEntries
  alias Terrible.Budgeting.Book

  attributes do
    uuid_primary_key :id

    attribute :date, :date do
      allow_nil? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true

      accept [:date]

      argument :book_id, :uuid do
        allow_nil? true
      end

      argument :entries, {:array, :map} do
        allow_nil? false
        constraints items: [
          fields: [
            source_id: [
              type: :uuid,
              allow_nil?: false
            ],
            source_type: [
              type: :atom,
              allow_nil?: false,
              constraints: [
                one_of: [:envelope]
              ]
            ],
            destination_id: [
              type: :uuid,
              allow_nil?: false
            ],
            destination_type: [
              type: :atom,
              allow_nil?: false,
              constraints: [
                one_of: [:envelope]
              ]
            ],
            amount: [
              type: :integer,
              allow_nil?: false
            ]
          ]
        ]
      end

      change manage_relationship(:book_id, :book, type: :append)
      change CreateTransactionEntries
    end
  end

  code_interface do
    define_for Terrible.Accounting
    define :create, action: :create
    define :destroy, action: :destroy
  end

  pub_sub do
    module TerribleWeb.Endpoint
    prefix "transactions"

    publish :create, ["created"]
    publish :update, ["updated", :id]
    publish :destroy, ["destroyed", :id]
  end

  relationships do
    belongs_to :book, Book do
      api Terrible.Budgeting
      allow_nil? false
    end

    has_many :transaction_entries, TransactionEntry
  end

  postgres do
    table "transactions"
    repo Terrible.Repo

    references do
      reference :book, on_delete: :delete
    end
  end
end
