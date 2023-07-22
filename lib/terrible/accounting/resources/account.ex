defmodule Terrible.Accounting.Account do
  @moduledoc """
  An Account is where transactions are stored under.
  """

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub]

  alias Terrible.Accounting.AccountType
  alias Terrible.Budgeting.Book

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :destroy]

    read :by_book_id do
      argument :id, :uuid, allow_nil?: false

      filter expr(book_id == ^arg(:id))
    end

    create :create do
      primary? true

      accept [:name]

      argument :account_type_id, :uuid do
        allow_nil? false
      end

      argument :book_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:account_type_id, :account_type, type: :append)
      change manage_relationship(:book_id, :book, type: :append)
    end

    update :update do
      primary? true

      accept [:name]
    end
  end

  code_interface do
    define_for Terrible.Accounting
    define :list_by_book_id, args: [:id], action: :by_book_id
    define :get, action: :read, get_by: [:id]
    define :create, action: :create
    define :update, action: :update
    define :destroy, action: :destroy
  end

  relationships do
    belongs_to :account_type, AccountType

    belongs_to :book, Book do
      api Terrible.Budgeting
    end
  end

  pub_sub do
    module TerribleWeb.Endpoint
    prefix "accounts"

    publish :create, ["created"]
    publish :update, ["updated", :id]
    publish :destroy, ["destroyed", :id]
  end

  postgres do
    table "accounts"
    repo Terrible.Repo

    references do
      reference :book, on_delete: :delete
    end
  end
end
