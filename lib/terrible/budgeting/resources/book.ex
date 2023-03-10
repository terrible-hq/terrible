defmodule Terrible.Budgeting.Book do
  @moduledoc """
  A Book is the catch-all container for a budget.
  """

  use Ash.Resource, data_layer: AshPostgres.DataLayer

  alias Terrible.Budgeting.{Budget, Category}

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :create, :update, :destroy]

    read :by_id do
      argument :id, :uuid, allow_nil?: false

      get? true

      filter expr(id == ^arg(:id))
    end
  end

  code_interface do
    define_for Terrible.Budgeting
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
  end

  relationships do
    has_many :budgets, Budget
    has_many :categories, Category
  end

  postgres do
    table "books"
    repo Terrible.Repo
  end
end
