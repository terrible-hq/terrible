defmodule Terrible.Accounting.Registry do
  @moduledoc false

  use Ash.Registry, extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry Terrible.Accounting.Account
    entry Terrible.Accounting.AccountType
  end
end
