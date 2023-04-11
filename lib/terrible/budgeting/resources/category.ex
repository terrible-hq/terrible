defmodule Terrible.Budgeting.Category do
  @moduledoc """
  A category is a group of envelopes
  """

  use Ash.Resource, data_layer: AshPostgres.DataLayer

  alias Terrible.Budgeting.{Book, Envelope}

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :update, :destroy]

    read :by_book_id do
      argument :id, :uuid, allow_nil?: false

      filter expr(book_id == ^arg(:id))
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false

      get? true

      filter expr(id == ^arg(:id))
    end

    create :create do
      primary? true
      accept [:name]

      argument :book_id, :uuid do
        allow_nil? false
      end

      argument :envelopes, {:array, :string} do
        allow_nil? true
      end

      change manage_relationship(:book_id, :book, type: :append)
      change manage_relationship(:envelopes, type: :create, value_is_key: :name)
    end
  end

  code_interface do
    define_for Terrible.Budgeting
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :list_by_book_id, args: [:id], action: :by_book_id
    define :get_by_id, args: [:id], action: :by_id
  end

  relationships do
    belongs_to :book, Book do
      allow_nil? false
    end

    has_many :envelopes, Envelope
  end

  postgres do
    table "categories"
    repo Terrible.Repo

    references do
      reference :book, on_delete: :delete
    end
  end
end
