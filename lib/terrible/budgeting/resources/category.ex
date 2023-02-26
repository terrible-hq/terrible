defmodule Terrible.Budgeting.Category do
  @moduledoc """
  A category is a group of envelopes
  """

  use Ash.Resource, data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :book_id, :uuid do
      allow_nil? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :create, :update, :destroy]

    read :by_book_id do
      argument :id, :uuid, allow_nil?: false

      get? true

      filter expr(book_id == ^arg(:id))
    end
  end

  code_interface do
    define_for Terrible.Budgeting
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_book_id, args: [:id], action: :by_book_id
  end

  relationships do
    belongs_to :book, Terrible.Budgeting.Book do
      allow_nil? false
    end
  end

  postgres do
    table "categories"
    repo Terrible.Repo

    custom_indexes do
      index ["book_id"]
    end
  end
end
