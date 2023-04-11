defmodule Terrible.AuthenticationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Terrible.Authentication` context.
  """

  alias Terrible.Authentication.User

  @doc """
  Generate a User.
  """
  def user_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        email: "test-#{System.unique_integer([:positive])}@example.com",
        hashed_password: Bcrypt.hash_pwd_salt("password123")
      })

    Ash.Seed.seed!(User, attrs)
  end
end
