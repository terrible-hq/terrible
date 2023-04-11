defmodule TerribleWeb.AuthenticationTestHelpers do
  @moduledoc """
  Helper functions for testing authentication.
  """

  alias Terrible.AuthenticationFixtures

  @doc """
  Setup helper that registers and logs in users.
      setup :register_and_log_in_user
  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = AuthenticationFixtures.user_fixture()

    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Setup helper that registers a user but does not log it in.
      setup :register_user
  """
  def register_user(_context) do
    %{
      user: AuthenticationFixtures.user_fixture()
    }
  end

  @doc """
  Logs the given `user` into the `conn`.
  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> AshAuthentication.Phoenix.Plug.store_in_session(user)
  end
end
