defmodule Terrible.Accounting.Registry do
  @moduledoc false

  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Terrible.Accounting.Transaction
    entry Terrible.Accounting.TransactionEntry
  end
end
