defmodule Terrible.Budgeting.Envelope do
  @moduledoc """
  An Envelope is the representation of a specific thing that you want to budget for.

  ## Examples

      Groceries
      Rent / Mortgage
      Home Maintenance
  """

  use Ash.Resource, data_layer: AshPostgres.DataLayer

  alias Terrible.Budgeting.Category

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :category_id, :uuid do
      allow_nil? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :create, :update, :destroy]

    read :by_category_id do
      argument :id, :uuid, allow_nil?: false

      get? true

      filter expr(category_id == ^arg(:id))
    end
  end

  code_interface do
    define_for Terrible.Budgeting
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :list_by_category_id, args: [:id], action: :by_category_id
  end

  relationships do
    belongs_to :category, Category do
      allow_nil? false
    end
  end

  postgres do
    table "envelopes"
    repo Terrible.Repo

    custom_indexes do
      index ["category_id"]
    end
  end
end
