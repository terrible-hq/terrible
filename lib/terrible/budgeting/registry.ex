defmodule Terrible.Budgeting.Registry do
  @moduledoc false

  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Terrible.Budgeting.Book
  end
end
