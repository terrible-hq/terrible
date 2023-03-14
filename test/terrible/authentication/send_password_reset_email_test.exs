defmodule Terrible.Authentication.SendPasswordResetEmailTest do
  use Terrible.DataCase
  use TerribleWeb, :verified_routes

  import Swoosh.TestAssertions

  alias AshAuthentication.Strategy.{Password, Password.Resettable}
  alias Terrible.Authentication.{Emails, SendPasswordResetEmail, User}

  describe "send/3" do
    setup [:create_fixtures]

    test "with valid user and url succeeds in sending a Password Reset email", %{user: user} do
      resettable = %Resettable{password_reset_action_name: :reset, token_lifetime: 36}
      strategy = %Password{resettable: [resettable], resource: User}

      {:ok, token} = Password.reset_token_for(strategy, user)

      SendPasswordResetEmail.send(user, token, nil)

      assert_email_sent(
        Emails.deliver_reset_password_instructions(user, url(~p"/password-reset/#{token}"))
      )
    end
  end

  defp create_fixtures(_) do
    user = user_fixture(%{email: "test_user@example.com"})

    %{user: user}
  end
end
