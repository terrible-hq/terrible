defmodule Terrible.Authentication.User do
  @moduledoc false
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  alias Terrible.Authentication
  alias Terrible.Authentication.SendPasswordResetEmail
  alias Terrible.Budgeting.{Book, BookUser}

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string, allow_nil?: false
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]

    read :by_id do
      argument :id, :uuid, allow_nil?: false

      get? true

      filter expr(id == ^arg(:id))
    end
  end

  code_interface do
    define_for Authentication
    define :read_all, action: :read
    define :get_by_id, args: [:id], action: :by_id
    define :register_with_password, args: [:email, :password, :password_confirmation]
  end

  authentication do
    api Authentication

    strategies do
      password :password do
        identity_field(:email)

        resettable do
          sender SendPasswordResetEmail
        end
      end
    end

    tokens do
      enabled? true
      token_resource Terrible.Authentication.Token

      signing_secret fn _, _ ->
        Application.fetch_env(:terrible, :token_signing_secret)
      end
    end
  end

  relationships do
    many_to_many :books, Book do
      through BookUser
      api Terrible.Budgeting
      source_attribute_on_join_resource :user_id
      destination_attribute_on_join_resource :book_id
    end
  end

  identities do
    identity :unique_email, [:email]
  end

  postgres do
    table "users"
    repo Terrible.Repo
  end
end
