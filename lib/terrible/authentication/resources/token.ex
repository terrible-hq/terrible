defmodule Terrible.Authentication.Token do
  @moduledoc """
  A token is a JWT used for various things like API
  authentication or password reset.
  """
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  token do
    api Terrible.Authentication
  end

  postgres do
    table "tokens"
    repo Terrible.Repo
  end
end
