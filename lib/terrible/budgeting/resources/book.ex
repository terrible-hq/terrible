defmodule Terrible.Budgeting.Book do
  @moduledoc """
  A Book is the catch-all container for a budget.
  """

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub]

  alias Terrible.Authentication.User
  alias Terrible.Budgeting.Book.Changes.CreateRelatedRecords
  alias Terrible.Budgeting.{BookUser, Budget, Category}

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :destroy]

    read :list do
      description "Returns a list of all Books available to the given user"

      argument :user_id, :uuid do
        allow_nil? false
      end

      filter expr(visible_to(user_id: arg(:user_id)))
    end

    create :create do
      accept [:name]
      primary? true
      change CreateRelatedRecords
    end

    update :update do
      accept [:name]
      primary? true
    end
  end

  code_interface do
    define_for Terrible.Budgeting
    define :list, args: [:user_id]
    define :get, action: :read, get_by: [:id]
    define :create, action: :create
    define :destroy, action: :destroy
  end

  pub_sub do
    module TerribleWeb.Endpoint
    prefix "books"

    publish :create, ["created"]
    publish :update, ["updated", :id]
    publish :destroy, ["destroyed", :id]
  end

  relationships do
    has_many :budgets, Budget
    has_many :categories, Category
    has_many :book_users, BookUser

    many_to_many :users, User do
      through BookUser
      join_relationship :book_users
      api Terrible.Authentication
      source_attribute_on_join_resource :book_id
      destination_attribute_on_join_resource :user_id
    end
  end

  calculations do
    calculate :visible_to,
              :boolean,
              expr(exists(users, id == ^arg(:user_id))) do
      argument :user_id, :uuid do
        allow_nil? false
      end
    end
  end

  postgres do
    table "books"
    repo Terrible.Repo
  end
end
