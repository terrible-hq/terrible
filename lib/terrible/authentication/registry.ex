defmodule Terrible.Authentication.Registry do
  @moduledoc false
  use Ash.Registry, extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry Terrible.Authentication.Token
    entry Terrible.Authentication.User
  end
end
