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
    hashed_password =
      attrs
      |> Map.get(:password, "password")
      |> Bcrypt.hash_pwd_salt()

    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "email-#{:rand.uniform(200)}@example.com",
        hashed_password: hashed_password
      })
      |> User.manual_create()

    user
  end
end
