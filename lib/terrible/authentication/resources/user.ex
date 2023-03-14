defmodule Terrible.Authentication.User do
  @moduledoc false
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

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

    create :manual_create do
      argument :attrs, :map, allow_nil?: false

      primary? false

      change fn changeset, _ ->
        attrs = Ash.Changeset.get_argument(changeset, :attrs)

        changeset
        |> Ash.Changeset.change_attribute(:email, attrs.email)
        |> Ash.Changeset.change_attribute(:hashed_password, attrs.hashed_password)
      end
    end
  end

  code_interface do
    define_for Terrible.Authentication
    define :manual_create, args: [:attrs], action: :manual_create
    define :read_all, action: :read
    define :get_by_id, args: [:id], action: :by_id
  end

  authentication do
    api Terrible.Authentication

    strategies do
      password :password do
        identity_field(:email)

        resettable do
          sender Terrible.Authentication.SendPasswordResetEmail
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

  identities do
    identity :unique_email, [:email]
  end

  postgres do
    table "users"
    repo Terrible.Repo
  end
end
