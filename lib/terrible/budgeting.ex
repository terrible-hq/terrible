defmodule Terrible.Budgeting do
  @moduledoc false

  use Ash.Api

  resources do
    registry Terrible.Budgeting.Registry
  end
end
