defmodule Terrible.Budgeting.BookUser do
  @moduledoc """
  Join table for Books and Users.
  """

  use Ash.Resource, data_layer: AshPostgres.DataLayer

  alias Terrible.Authentication.User
  alias Terrible.Budgeting.Book

  attributes do
    uuid_primary_key :id

    attribute :role, :atom do
      allow_nil? false

      constraints one_of: [:guest, :member, :owner]
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:role]
      primary? true
      upsert? true
      upsert_identity :unique_book_user

      argument :book_id, :uuid do
        allow_nil? false
      end

      argument :user_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:book_id, :book, type: :append)
      change manage_relationship(:user_id, :user, type: :append)
    end
  end

  code_interface do
    define_for Terrible.Budgeting
    define :create, action: :create
    define :destroy, action: :destroy
  end

  relationships do
    belongs_to :book, Book do
      attribute_writable? true
      allow_nil? false
    end

    belongs_to :user, User do
      api Terrible.Authentication
      attribute_writable? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_book_user, [:book_id, :user_id]
  end

  postgres do
    table "book_users"
    repo Terrible.Repo

    references do
      reference :book, on_delete: :delete
      reference :user, on_delete: :delete
    end
  end
end
