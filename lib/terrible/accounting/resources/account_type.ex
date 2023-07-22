defmodule Terrible.Accounting.AccountType do
  @moduledoc """
  An AccountType is a classification of an Account.
  """

  use Ash.Resource, data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false

    attribute :type, :atom do
      allow_nil? false

      constraints one_of: [:asset, :liability]
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :create]
  end

  code_interface do
    define_for Terrible.Accounting
    define :list, action: :read
  end

  postgres do
    table "account_types"
    repo Terrible.Repo
  end
end
