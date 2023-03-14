defmodule Terrible.Authentication do
  @moduledoc false
  use Ash.Api

  resources do
    registry Terrible.Authentication.Registry
  end
end
