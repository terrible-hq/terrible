defmodule Terrible.Budgeting.Registry do
  @moduledoc false

  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Terrible.Budgeting.Book
    entry Terrible.Budgeting.Budget
    entry Terrible.Budgeting.Category
    entry Terrible.Budgeting.Envelope
  end
end
