defmodule Terrible.Accounting do
  @moduledoc false
  use Ash.Api

  resources do
    registry Terrible.Accounting.Registry
  end
end
