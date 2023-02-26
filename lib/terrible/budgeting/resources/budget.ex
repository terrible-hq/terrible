defmodule Terrible.Budgeting.Budget do
  @moduledoc """
  A Budget is a representation of a budget for a specific month
  """

  use Ash.Resource, data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false

      constraints match: ~r/^\d{6}$/
    end

    attribute :month, :date do
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

    read :get_by_book_id_and_name do
      argument :id, :uuid, allow_nil?: false
      argument :name, :string, allow_nil?: false

      get? true

      filter expr(book_id == ^arg(:id) and name == ^arg(:name))
    end
  end

  code_interface do
    define_for Terrible.Budgeting
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_book_id_and_name, args: [:id, :name], action: :get_by_book_id_and_name
  end

  relationships do
    belongs_to :book, Terrible.Budgeting.Book do
      allow_nil? false
    end
  end

  identities do
    identity :book_budget_pair, [:book_id, :name]
  end

  postgres do
    table "budgets"
    repo Terrible.Repo

    custom_indexes do
      index ["month"]
    end
  end
end
