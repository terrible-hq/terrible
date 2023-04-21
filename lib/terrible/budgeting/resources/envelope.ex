defmodule Terrible.Budgeting.Envelope do
  @moduledoc """
  An Envelope is the representation of a specific thing that you want to budget for.

  ## Examples

      Groceries
      Rent / Mortgage
      Home Maintenance
  """

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub]

  alias Terrible.Budgeting.{Book, Category, MonthlyEnvelope}
  alias Terrible.Budgeting.Envelope.Changes.CreateMonthlyEnvelopes

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :type, :atom do
      default :standard

      constraints one_of: [:standard, :unassigned]
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :update, :destroy]

    read :by_category_id do
      argument :category_id, :uuid, allow_nil?: false

      filter expr(category_id == ^arg(:id))
    end

    create :create do
      primary? true
      accept [:name, :type]

      argument :book_id, :uuid do
        allow_nil? true
      end

      argument :category_id, :uuid do
        allow_nil? true
      end

      change manage_relationship(:book_id, :book, type: :append)
      change manage_relationship(:category_id, :category, type: :append)
      change CreateMonthlyEnvelopes
    end
  end

  code_interface do
    define_for Terrible.Budgeting
    define :create
    define :read_all, action: :read
    define :get, action: :read, get_by: [:id]
    define :update, action: :update
    define :destroy, action: :destroy
    define :list_by_category_id, args: [:category_id], action: :by_category_id
  end

  pub_sub do
    module TerribleWeb.Endpoint
    prefix "envelopes"

    publish :create, ["created"]
    publish :update, ["updated", :id]
    publish :destroy, ["destroyed", :id]
  end

  relationships do
    belongs_to :book, Book do
      allow_nil? false
    end

    belongs_to :category, Category do
      allow_nil? false
    end

    has_many :monthly_envelopes, MonthlyEnvelope
  end

  postgres do
    table "envelopes"
    repo Terrible.Repo

    references do
      reference :book, on_delete: :delete
      reference :category, on_delete: :delete
    end

    custom_indexes do
      index [:book_id, :type], unique: true, where: "type = 'unassigned'"
    end
  end
end
